from pydoc import tempfilepager
import openai
import os
import re
from dotenv import load_dotenv

load_dotenv()

openai.api_key = os.environ.get("OPENAI_API_KEY")

def get_keyphrase_from_gpt(text_prompt):
    extract_prompt = \
        '''
        I will provide phrases or sentences, and you should extract the most relevant subject along with its descriptors 
        that should be detected by an object detection model. Respond only with the subject and its relevant descriptors and nothing else.
        
        Example:
        Sentence: Bookshelf
        bookshelf

        Example:
        Sentence: A jaguar
        jaguar

        Example:
        Sentence: this is a ball of yarn
        ball of yarn

        Example:
        Sentence: I saw a beautiful car on the road.
        car

        Example:
        Sentence: I want to catch this red water bottle right now.
        red water bottle

        Example:
        Sentence: No way! That's a black capped chickadee!
        black-capped chickadee
        
        Example:
        Sentence: "{}"
        '''.format(text_prompt)
    
    response = openai.Completion.create(
        model='gpt-3.5-turbo-instruct', 
        prompt=extract_prompt,
        max_tokens=15,
        temperature=0
        )
    
    keyphrase = response["choices"][0]["text"]
    lines = keyphrase.split('\n')
    keyphrase = next((line for line in lines if line.strip() != ''), "")
    keyphrase = re.sub(r'[^a-zA-Z0-9 ]', '', keyphrase).strip()
    
    return keyphrase.title()

def main():
    text_prompt = input("Text Prompt: ")
    keyphrase = get_keyphrase_from_gpt(text_prompt)
    print(keyphrase)

if __name__ == "__main__":
    main()