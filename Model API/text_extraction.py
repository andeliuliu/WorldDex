from pydoc import tempfilepager
import openai
import os
import re

openai.api_key = os.getenv('OPENAI_API_KEY')

def get_keyphrase_from_gpt(text_prompt):
    extract_prompt = \
        '''
        I will provide sentences, and you should extract the most relevant subject 
        that should be detected by an object detection model. Respond only with the subject phrase and nothing else.
        
        Example:
        Sentence: I saw a beautiful car on the road.
        car
        
        Example:
        Sentence: The sunset was interrupted by a passing airplane.
        airplane
        
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