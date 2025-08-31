# HTTP Hot Reload Server (**hhotserve**)

Server that serves static files and supports hot reloading for web development extending `http.server` and `watchdog`.

## Installation and usage
- **Using the installation script (easiest way)**
```bash
curl -sSL https://raw.githubusercontent.com/ndy7stillx86ihz/hhotserve/main/install.sh | bash
```

- **Using UV**

```bash
uv run hhotserve.py .
```
- **As an executable**
    1. Install the **watchdog** dependency system-wide:
    ```bash
    # in debian
    sudo apt install python3-watchdog
    ```
    2. Make the script executable:
    ```bash
    chmod +x hhotserve.py
    ```
    3. Run the server:
    ```bash
    ./hhotserve.py .
    ```
  
- **As a system executable**
  - Follow the steps (**i.,ii.**) above to make it executable.
  - Move it to a directory in your PATH, e.g.:
    ```bash
    sudo mv hhotserve.py /usr/local/bin/hhotserve
    ```
    - Now you can run it from anywhere:
        ```bash
        hhotserve .
        ```

## MAKE PULL REQUESTS FOR IMPROVEMENTS!