import os
import time
import random

from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello_world():
   # Sleep for 56 seconds + random time between 0 and 2 second
   time.sleep(56 + random.uniform(0, 2))

   return f"APP2: Time is {time.ctime()} in Process ID {os.getpid()}\n"

if __name__ == "__main__":
   app.run(debug=True,host='0.0.0.0',port=int(os.environ.get('PORT', 8080)))