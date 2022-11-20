import os
import time
import random

from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello_world():
   with open("file_32MB", "rb") as f:
      file = f.read()
   # Sleep for 1 seconds + random time between 0 and 0.5 second
   time.sleep(1 + random.uniform(0, 0.5))

   return f"APP2: Time is {time.ctime()} in Process ID {os.getpid()}\n"

if __name__ == "__main__":
   app.run(debug=True,host='0.0.0.0',port=int(os.environ.get('PORT', 8080)))