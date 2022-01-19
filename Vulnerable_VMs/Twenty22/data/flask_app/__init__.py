from flask import render_template,make_response,request,Flask,render_template_string

app = Flask(__name__)

def check_cookie():
    try:
        the_cookie = request.cookies.get('user')
        if len(the_cookie) > 0:
            return True
    except:
        return False

@app.route('/')
def home():
    if check_cookie():
        return render_template('challenges.html')
    else:
        return render_template('login.html')
        
@app.route('/scoreboard')
def scoreboard():
    if check_cookie():
        return render_template('scoreboard.html')
    else:
        return render_template('login.html')

@app.route('/users')
def users():
    if check_cookie():
        return render_template('users.html')
    else:
        return render_template('login.html')

@app.route('/challenges')
def challenges():
    if check_cookie():
        the_cookie = request.cookies.get('user')
        return render_template_string('''
        {% extends 'challenges.html' %}
        {%block name%}''' 
        + f'''{the_cookie}''' +
        '''{%endblock name%}''')
    else:
        return render_template('login.html')

@app.route('/logout')
def logout():
    resp = make_response(render_template('login.html'))
    resp.delete_cookie('user')
    return resp

@app.route('/login',methods=['post'])
def login():
    username = request.form['username']
    password = request.form['password']

    resp = make_response(render_template_string('''
        {% extends 'challenges.html' %}
        {%block name%}''' 
        + f'''{username}''' +
        '''{%endblock name%}'''))
    resp.set_cookie('user',username)
    return resp

if __name__ == "__main__":
    app.run(host='0.0.0.0',port=80)