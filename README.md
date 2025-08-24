````markdown
# GitHub Actions Self-Hosted Runner Setup

This repository provides scripts to install and maintain a **self-hosted GitHub Actions runner** on a Linux server (e.g. Ubuntu).  
It also includes a **watchdog service** that makes sure the runner restarts automatically if it crashes or gets stuck.

---

## 📦 Scripts

### 1. `setup-runner.sh`
Installs and configures a GitHub Actions runner as a `systemd` service.  
The runner is set to always restart if it exits.

**Usage:**
```bash
./scripts/setup-runner.sh <RUNNER_TOKEN>
````

* Replace `<RUNNER_TOKEN>` with the registration token from GitHub:

  * Go to **Repo / Settings / Actions / Runners / New self-hosted runner**
  * Copy the **Registration token** and pass it to the script.

By default, the script installs into `~/actions-runner`, registers with the repo `MorrisMorrison/schist`, and creates a systemd service named:

```
actions.runner.MorrisMorrison-schist.netcup-runner.service
```

---

### 2. `setup-watchdog.sh`

Installs a **watchdog systemd timer** that checks every 5 minutes if the runner service is still active.
If the service is inactive, it restarts it automatically.

**Usage:**

```bash
./scripts/setup-watchdog.sh
```

The watchdog logs any restarts to:

```
/var/log/runner-watchdog.log
```

---

## 🔧 Requirements

* Linux server (tested on Ubuntu/Debian)
* `curl`, `tar`, `jq`, and `systemd` available
* User account with `sudo` privileges
* A GitHub repository or organization with Actions enabled

---

## 🛠️ Service Management

After installation, you can manage the runner like any other systemd service:

```bash
# Check status
sudo systemctl status actions.runner.MorrisMorrison-schist.netcup-runner.service

# Restart manually
sudo systemctl restart actions.runner.MorrisMorrison-schist.netcup-runner.service

# View logs
journalctl -u actions.runner.MorrisMorrison-schist.netcup-runner.service -f
```

Watchdog status:

```bash
systemctl status runner-watchdog.timer
journalctl -u runner-watchdog.service
```

---

## 🚀 Workflow

1. Run `setup-runner.sh` with your GitHub token
2. Run `setup-watchdog.sh` to add the watchdog
3. Verify that the runner shows up in your repo under **Settings → Actions → Runners**
4. Use it in your workflow:

```yaml
runs-on: self-hosted
```

---

## ⚠️ Notes

* Tokens expire quickly (usually in 1 hour). Always generate a fresh token before running `setup-runner.sh`.
* If you want **organization-level runners**, leave `GITHUB_REPO` empty inside `setup-runner.sh`.
* Adjust the watchdog timer interval in `setup-watchdog.sh` if you need faster/later checks.

---

## 📝 License

MIT

```

---

Would you like me to also add an **example GitHub Actions workflow file** (`.github/workflows/test-runner.yml`) to the repo so you can immediately test the runner after setup?
```

