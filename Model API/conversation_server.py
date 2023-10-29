import os
import openai
import numpy as np
import json
import elevenlabs
import time
from flask import Flask, request, Response, session, stream_with_context, jsonify
from flask_session import Session
from elevenlabs import set_api_key, generate, stream
from dotenv import load_dotenv

app = Flask(__name__)

load_dotenv()
set_api_key(os.environ.get("ELEVENLABS_API_KEY"))
openai.api_key = os.environ.get("GPT4_API_KEY")
if not openai.api_key:
    raise ValueError("API Key for OpenAI not set!")

app.config['SECRET_KEY'] = os.urandom(24)
app.config['SESSION_TYPE'] = 'filesystem'
Session(app)

def _call_openai(messages, function_info=None, max_retries=1, wait_time=1):
        """
        Communicate with the OpenAI API to get a response.

        Parameters:
        - messages: List of message dictionaries to send.
        - function_info: Optional dictionary containing function details.
        - max_retries: Number of times to retry in case of a JSONDecodeError.
        - wait_time: Time in seconds to wait between retries.
        - examples: List of example dictionaries.

        Returns:
        - The response message from OpenAI API.
        """

        functions = [function_info] if function_info else []          

        retries = 0
        while retries < max_retries:
            try:
                if functions:
                    response = openai.ChatCompletion.create(
                        model="gpt-4",
                        messages=messages,
                        functions=functions,
                        temperature=0
                    )
                else:
                    response = openai.ChatCompletion.create(
                        model="gpt-4",
                        messages=messages,
                        temperature=0
                    )

                response_message = response["choices"][0]["message"]
                return response_message
            except json.JSONDecodeError:
                retries += 1
                time.sleep(wait_time)

        raise Exception("Maximum retries reached. API issues.")

def elevenlabs_tts_stream(text, voice='Liam'):
    if len(text) > 2000:
        return text[:2000]
    audio_stream = generate(text, voice=voice, stream=True)
    return audio_stream

@app.route('/respond', methods=['POST'])
def respond():
    data = request.json
    response_text = data['text']
    subject_name = data['image_name']

    # Check if the subject has changed
    previous_subject = session.get('subject_name', None)
    if previous_subject != subject_name:
        # Reset messages if the subject has changed
        session['messages'] = []
    
    # Retrieve or initialize messages list from session
    messages = session.get('messages', [])
    if not messages:
        system_message = {
        "role": "system",
        "content": '''
            You are a PokeDex for real life, designed to provide concise and interesting facts about objects and creatures in a factual and somewhat robotic tone. Your responses should be brief, containing a maximum of two short facts about the subject. 

            Focus on delivering unique and informative content about the subject, similar to how a Pokedex would describe a Pokemon. Your tone should be neutral and informative, and your responses should be precise and to the point.
            
            After the initial introduction for the subject, you do not need to repeat the subject name; instead you continue the conversation, answering the requests from the user about the subject in the same style.

            Example 1:
            Subject: Red Apple
            User: Can you tell me about this?
            Response: Red apple. There are over 7,000 varieties of apples worldwide. The red apple is rich in antioxidants, beneficial for health.
            User: How are green ones different?
            Response: Green apples tend to be more tart and less sweet than red varieties. They're often used in cooking due to their firm texture and acidity.
            User: What's the most popular variety?
            Response: Golden Delicious apples are one of the most widely recognized apple varieties, known for its sweet flavor and versatility in both cooking and fresh consumption.
            User: Can apples grow in tropical climates?
            Response: Apples typically have limited growth in tropical climates because they require cold periods to induce fruiting. Some low-chill varieties can grow in warmer climates, but true tropical conditions are not ideal for apple cultivation.

            Example 2:
            Subject: Rusty Key
            User: What is this?
            Response: Rusty key. Keys have been used for centuries to secure and protect valuables. Rust forms on keys due to prolonged exposure to moisture.
            User: Why does rust form?
            Response: Rust, or iron oxide, forms when iron reacts with oxygen in the presence of moisture. It is a natural process of corrosion that degrades the iron.
            User: Can it be restored?
            Response: Yes, minor rust can often be removed using abrasive methods or chemical removers. For severely rusted keys, restoration may be challenging, and it might be better to preserve rather than restore.
            User: How were keys made in ancient times?
            Response: In ancient times, keys were hand-forged by blacksmiths, typically made of iron or bronze. The designs were simpler, relying on basic lock mechanisms.

            Subject: Quartz Crystal
            User: Can you identify this for me?
            Response: Quartz crystal. Quartz is one of the most abundant minerals on Earth. It's valued for its clarity and hexagonal crystal shape.

            User: What properties does it have?
            Response: Quartz has piezoelectric properties, meaning it generates an electric charge under mechanical stress. This property makes it useful in electronic devices like watches and radios.

            User: How is it formed?
            Response: Quartz forms from cooling magma or in hydrothermal veins. Over time, silicic acid or silica-rich water solidifies to form quartz crystals in cavities within rocks.

            User: Why are some quartz colored?
            Response: The variety of colors in quartz crystals is due to impurities or trace elements. For instance, amethyst, a purple variety, gets its color from iron and irradiation.
        '''
        }
        messages = [system_message]

        subject_intro_message = {
            "role": "system",
            "content": f"Subject: {subject_name}"
        }
        messages.append(subject_intro_message)

    messages.append({
        "role": "user",
        "content": response_text
    })
    
    openai_response = _call_openai(messages)

    # Save updated messages to session
    session['messages'] = messages
    session['subject_name'] = subject_name

    audio_stream = generate(openai_response['content'], voice='Liam', stream=True)

    def generate_audio():
        for chunk in audio_stream:
            yield chunk

    return Response(stream_with_context(generate_audio()), content_type='audio/wav')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)