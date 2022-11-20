import os
import time
import random

from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello_world():
   # load file file_16MB
   with open("file_16MB", "rb") as f:
      file = f.read()

   time.sleep(random.uniform(0, 0.5))

   return f"APP1: Time is {time.ctime()} in Process ID {os.getpid()}\n"

if __name__ == "__main__":
   app.run(debug=True,host='0.0.0.0',port=int(os.environ.get('PORT', 8080)))