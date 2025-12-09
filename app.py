from flask import Flask, render_template, request, jsonify
import sqlite3
import os

app = Flask(
    __name__,
    template_folder='.',
    static_folder='.',
    static_url_path=''
)

DB_PATH = "ProjectDB.db"


def get_db():
    """Create a database connection with row factory for dict-like access"""
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


# ---------- PAGE ROUTES ----------

@app.route("/")
def home():
    """Home page"""
    return render_template("project main.html")


@app.route("/library")
def library():
    """Library page - shows all articles from database"""
    return render_template("library.html")


@app.route("/faq")
def faq_page():
    """FAQ page"""
    return render_template("faq.html")


@app.route("/contact", methods=["GET", "POST"])
def contact():
    """Contact form page"""
    if request.method == "POST":
        subject = request.form.get("subject")
        category_id = request.form.get("categoryID")
        message = request.form.get("submissionMessage")

        if not subject or not category_id or not message:
            return """
            <h1>Error</h1>
            <p>All fields are required.</p>
            <p><a href="/contact">Go back</a></p>
            """

        viewer_id = 1  # sample user from SQL

        conn = get_db()
        cur = conn.cursor()
        cur.execute("""
            INSERT INTO "submissions"
                ("viewerID", "subject", "submissionMessage", "statusID", "categoryID")
            VALUES (?, ?, ?, 'new', ?)
        """, (viewer_id, subject, message, category_id))
        conn.commit()
        submission_id = cur.lastrowid
        conn.close()

        return f"""
        <!DOCTYPE html>
        <html>
        <head>
            <link rel="stylesheet" href="/project_styles.css">
        </head>
        <body>
            <div class="grid-container">
                <header class="header">
                    <h1>Open MRS</h1>
                </header>
                <main class="content">
                    <h1>Thank you!</h1>
                    <p>Your message has been submitted successfully.</p>
                    <p><strong>Reference ID:</strong> {submission_id}</p>
                    <p><a href="/contact">Submit another message</a></p>
                    <p><a href="/">Return to Home</a></p>
                </main>
                <footer class="footer">
                    <p>
                        <a href="/">Home</a> |
                        <a href="/library">Library</a> |
                        <a href="/faq">FAQs</a> |
                        <a href="/contact">Contact Us</a>
                    </p>
                </footer>
            </div>
        </body>
        </html>
        """

    return render_template("contact.html")


# ---------- API ROUTES ----------

@app.route("/api/faqs")
def api_get_faqs():
    """API endpoint to get all FAQs"""
    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
        SELECT
            f."entryID",
            f."question",
            f."answer",
            c."nameOfCategory"
        FROM "faq entry" AS f
        JOIN "category" AS c
          ON f."categoryID" = c."categoryID"
        ORDER BY f."entryID" DESC
    """)
    rows = [dict(r) for r in cur.fetchall()]
    conn.close()
    return jsonify(rows)


if __name__ == "__main__":
    if not os.path.exists(DB_PATH):
        print("WARNING: ProjectDB.db not found.")
        print("Run: python3 init_db.py")
    port = int(os.environ.get("PORT", 5001))
    app.run(debug=False, host='0.0.0.0', port=port)
