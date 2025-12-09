BEGIN TRANSACTION;

----------------------------------------------------------------
-- 1. CORE USER TABLE
----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "viewer info" (
    "viewerID"      INTEGER PRIMARY KEY AUTOINCREMENT,
    "username"      VARCHAR(100) NOT NULL,
    "userEmail"     VARCHAR(255) NOT NULL UNIQUE
                    CHECK("userEmail" LIKE '%_@__%.__%')
);

----------------------------------------------------------------
-- 2. CATEGORY TABLE (USED BY FAQs + ARTICLES + SUBMISSIONS)
----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "category" (
    "categoryID"           INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "nameOfCategory"       VARCHAR(100) NOT NULL UNIQUE,
    "categoryDescription"  TEXT NOT NULL
);

----------------------------------------------------------------
-- 3. FAQ ENTRY + FAQ RATING
----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "faq entry" (
    "entryID"      INTEGER PRIMARY KEY AUTOINCREMENT,
    "categoryID"   INT NOT NULL,
    "question"     TEXT NOT NULL,
    "answer"       TEXT NOT NULL,
    "date"         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("categoryID") REFERENCES "category"("categoryID")
);

CREATE TABLE IF NOT EXISTS "faq rating" (
    "entryID"      INTEGER,
    "ratingID"     INTEGER PRIMARY KEY AUTOINCREMENT,
    "viewerID"     INT,
    "ratingValue"  INT NOT NULL CHECK("ratingValue" BETWEEN 1 AND 5),
    "date"         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("entryID") REFERENCES "faq entry"("entryID"),
    FOREIGN KEY ("viewerID") REFERENCES "viewer info"("viewerID")
);

----------------------------------------------------------------
-- 4. ARTICLES (HEALTH TIPS / LIBRARY) + BOOKMARKS + ARTICLE VIEWS
----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "articles" (
    "articleID"       INTEGER PRIMARY KEY AUTOINCREMENT,
    "nameOfArticle"   VARCHAR(200) NOT NULL,
    "articleContent"  TEXT NOT NULL,
    "viewcount"       INT NOT NULL DEFAULT 0,
    "datePublished"   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "categoryID"      INT,
    FOREIGN KEY ("categoryID") REFERENCES "category"("categoryID")
);

CREATE TABLE IF NOT EXISTS "bookmarks" (
    "bookmarkID"  INTEGER PRIMARY KEY AUTOINCREMENT,
    "articleID"   INT,
    "viewerID"    INT,
    FOREIGN KEY ("articleID") REFERENCES "articles"("articleID"),
    FOREIGN KEY ("viewerID")  REFERENCES "viewer info"("viewerID")
);

CREATE TABLE IF NOT EXISTS "article views" (
    "viewerID"        INT,
    "articleID"       INT,
    "articleViewsID"  INTEGER PRIMARY KEY AUTOINCREMENT,
    "dateViewed"      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("viewerID")  REFERENCES "viewer info"("viewerID"),
    FOREIGN KEY ("articleID") REFERENCES "articles"("articleID")
);

----------------------------------------------------------------
-- 5. CONTACT / SUPPORT FEATURE TABLES
----------------------------------------------------------------

-- 5a. Submission confirmation (reference number)
CREATE TABLE IF NOT EXISTS "submission confirmation" (
    "confirmationID"  INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "referenceNumber" VARCHAR(20) NOT NULL UNIQUE,
    "viewerID"        INT,
    "submissionID"    INT,
    FOREIGN KEY ("viewerID")   REFERENCES "viewer info"("viewerID"),
    FOREIGN KEY ("submissionID") REFERENCES "submissions"("submissionID")
);

-- 5b. Submissions (contact form entries)
-- NOTE:
--  - statusID is a TEXT status field with a CHECK constraint
--  - categoryID links to "category" for Technical Support / Billing / Feedback
CREATE TABLE IF NOT EXISTS "submissions" (
    "submissionID"      INTEGER PRIMARY KEY AUTOINCREMENT,
    "viewerID"          INT,
    "subject"           VARCHAR(200) NOT NULL,
    "submissionMessage" TEXT NOT NULL,
    "submissionDate"    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "statusID"          TEXT NOT NULL DEFAULT 'new'
                         CHECK("statusID" IN ('new', 'pending', 'in progress', 'resolved')),
    "confirmationID"    INT,
    "categoryID"        INT,
    FOREIGN KEY ("viewerID")       REFERENCES "viewer info"("viewerID"),
    FOREIGN KEY ("confirmationID") REFERENCES "submission confirmation"("confirmationID"),
    FOREIGN KEY ("categoryID")     REFERENCES "category"("categoryID")
);

-- 5c. Submission status history (optional status log per submission)
CREATE TABLE IF NOT EXISTS "submission status" (
    "statusID"      INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "statusInfo"    VARCHAR(500),
    "viewerID"      INT,
    "submissionID"  INT,
    "date"          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("viewerID")     REFERENCES "viewer info"("viewerID"),
    FOREIGN KEY ("submissionID") REFERENCES "submissions"("submissionID")
);

----------------------------------------------------------------
-- 6. SAMPLE DATA (GOOD FOR TESTING + DEMO)
----------------------------------------------------------------

-- One test viewer (works with Flask assuming viewerID = 1)
INSERT INTO "viewer info" ("username", "userEmail")
VALUES ('testuser', 'test@example.com');

-- Categories (used by contact form + FAQs + articles)
INSERT INTO "category" ("nameOfCategory", "categoryDescription") VALUES
('Technical Support', 'Questions about logging in, bugs, and system issues.'),
('Billing Inquiry',   'Questions about payments, invoices, and charges.'),
('General Feedback',  'Suggestions and general comments.');

-- Sample FAQ entries
INSERT INTO "faq entry" ("categoryID", "question", "answer") VALUES
(1, 'How do I reset my password?',
    'Click on "Forgot Password" on the login page and follow the reset link sent to your email.'),
(3, 'What is OpenMRS used for?',
    'OpenMRS is an open-source medical record system used to manage patient data, especially in resource-constrained environments.'),
(3, 'Can I contribute to the project?',
    'Yes! You can contribute code, documentation, or testing by visiting the OpenMRS community website.');

-- Sample article
INSERT INTO "articles" ("nameOfArticle", "articleContent", "categoryID") VALUES
('Staying Healthy with OpenMRS',
 'Learn how to use the OpenMRS patient portal to track appointments, medications, and lab results.',
 3);

-- Sample submission (matches your contact feature)
INSERT INTO "submissions" ("viewerID", "subject", "submissionMessage", "statusID", "categoryID")
VALUES (
    1,
    'Cannot log in',
    'I forgot my password and the reset link is not working.',
    'new',
    1
);

COMMIT;