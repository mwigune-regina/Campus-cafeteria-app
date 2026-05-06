# PostgreSQL Setup Guide for Campus Cafeteria App

This guide walks you through installing PostgreSQL, creating the database, and setting up the tables required for the backend API.

## 1. Installation

1.  **Run the Installer**: Double-click the downloaded PostgreSQL installer (v17.x or v18.x).
2.  **Components**: Ensure all boxes are checked:
    *   PostgreSQL Server
    *   pgAdmin 4 (Graphical management tool)
    *   Stack Builder
    *   Command Line Tools
3.  **Password**: When prompted for a password for the `postgres` user, **set a strong password and write it down**. You will need this for the `.env` file.
4.  **Port**: Use the default port `5432`.
5.  **Finish**: Complete the installation and launch **pgAdmin 4**.

---

## 2. Database Creation (via pgAdmin 4)

1.  **Open pgAdmin 4**: It will open in your web browser or as a standalone app.
2.  **Connect**: Click on **Servers** > **PostgreSQL [Version]** and enter the password you set during installation.
3.  **Create DB**:
    *   Right-click on **Databases**.
    *   Select **Create** > **Database...**
    *   In the **Database** field, type: `cafeteria_db`.
    *   Click **Save**.

---

## 3. Applying the Schema (Creating Tables)

1.  **Open Query Tool**: Right-click on your newly created `cafeteria_db` and select **Query Tool**.
2.  **Copy SQL**: Open the file `backend/models/db_schema.sql` in your project. Copy the entire content of that file.
3.  **Execute**:
    *   Paste the SQL code into the Query Tool window in pgAdmin.
    *   Click the **Execute/Refresh** icon (Play button) or press **F5**.
    *   Verify the message at the bottom: `Query returned successfully`.

---

## 4. Connecting the Backend

1.  Open your `backend/.env` file.
2.  Update the following lines with your specific details:
    ```env
    DB_USER=postgres
    DB_PASSWORD=YOUR_POSTGRES_PASSWORD_HERE
    DB_NAME=cafeteria_db
    DB_HOST=localhost
    DB_PORT=5432
    ```
3.  Save the file.

---

## 5. Verification

1.  Open a terminal in the `backend/` folder.
2.  Run the command:
    ```bash
    npm.cmd run dev
    ```
3.  If you see `Server running on port 3000`, the connection is successful!

---

### Troubleshooting
*   **Connection Refused**: Ensure the PostgreSQL service is running in Windows Services.
*   **Authentication Failed**: Double-check the password in your `.env` matches what you set during installation.
*   **Database Does Not Exist**: Ensure the `DB_NAME` in `.env` exactly matches the name you gave in pgAdmin (`cafeteria_db`).
