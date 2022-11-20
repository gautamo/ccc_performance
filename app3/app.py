import os
import time
import random

from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello_world():
   with open("file_64MB", "rb") as f:
      file = f.read()
   # Sleep for 2.5 seconds + random time between 0 and 2 second
   time.sleep(2.5 + random.uniform(0, 0.5))

   return f"APP3: Time is {time.ctime()} in Process ID {os.getpid()}\n"

if __name__ == "__main__":
   app.run(debug=True,host='0.0.0.0',port=int(os.environ.get('PORT', 8080)))