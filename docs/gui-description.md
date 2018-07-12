
## Describing the application GGPG

### 01. On start check for valid key

  - When application starts, it should check for an existing valid
    key.  If no valid key exists, it should display a dialog box like
    this:

    ![](img/novalidkey.png)


### 02. Check for key expiration

  - When application starts and there is a valid key, it should check
    also for the expiration of the key. If key expires in less than 1
    month it should give a warning and offer to renew it:

    ![](img/key-is-expiring.png)

  - If the key has already expired, the user should be promted to
    renew or delete it:

    ![](img/key-has-expired.png)


### 03. Main window

  - When the application starts and the key is Ok, it displays the main
    window, which looks like this:

    ![](img/main-box.png)

  - **Sign a file**::
    When the button is clicked, the application does these steps:
     + Open the dialog box for selecting a file.
     + After a file is selected displays a form with metadata about
       the file, like timestamp, title, description, comments, etc.
       This information will be signed together with the file, and
       will be saved together with the signature.
     + When the file is signed, displays an information/confirmation
       window, and then returns to the main window.

    ![](img/sign-file.png)

  - **Verify a signature**:
    When the button is clicked, the app does these:
     + Open the dialog box for selecting a file.
     + Verify the signature.
     + Display any error or information messages (whether the
       signature is correct or not, if correct by whom was signed, any
       metadata, etc.) For example:
       ```
       File: ....
       Good signature from: Dashamir Hoxha <dashohoxha@gmail.com> (verified)
       Fingerprint: 040E FEF9 081A 6B44 A0F7 CE6C FA82 4ADB A836 945C
       Time of signature: ....
       Title:
       Description:
       ```
     + If the person who signed the docs is not on the contact list,
       it should ask to search for him online. If found, should ask
       to save him on the contact list.
