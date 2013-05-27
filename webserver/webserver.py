from bottle import route, run, request, response
import sqlite3
import sys

@route('/sentiment')
def getsentiment():
	# connect to the database
	con = sqlite3.connect("../twitter.db")
	with con:
		con.row_factory = sqlite3.Row
		# fetch all the rows with RED in them.
		sql = "SELECT * FROM twitterdata ORDER BY rowId DESC limit 50"
		cur = con.cursor()
		cur.execute(sql)
		dataout = cur.fetchall()
		html = []
		html.append("<html><head><title>Latest Sentiment Scores</title></head><body>")
		html.append("<table>")
		html.append("<tr><td>User</td><td>Tweet</td><td>Score</td></tr>")
	        for row in dataout:
			html.append("<tr><td>")
			html.append(row["twitteruser"])
			html.append("</td><td>")
			html.append(row["twitterdata"])
			html.append("</td><td>")
			html.append(str(row["sentimentscore"]))
			html.append("</td></tr>")	
		html.append("</table>")
		html.append("</body>")
		html.append("</html>")
		return ' '.join(html)


# this line makes the webserver run 
run(host='192.168.2.2', port='8000', debug=True)
