# Invidious.nerdvpn.de
Invidious fork with customizations for invidious.nerdvpn.de

Theme for my instance is based on: https://github.com/Tsyron/Invidious-Theme

Original repo at: https://github.com/iv-org/invidious

Based upon patches from: https://github.com/yewtudotbe/invidious-custom


# Build instructions

1. `git clone https://github.com/Sommerwiesel/invidious-nerdvpn .`
2. `git clone https://github.com/iv-org/invidious build`
3. `./patch.sh`
4. `./build.sh development` for the development image or `./build.sh release` for the production image

# Update instructions

- Simply run `./update.sh`

# Run instructions (docker compose)

- For the database: `docker compose --profile database up -d`
- For the worker: `docker compose --profile worker up -d` 
- For the web client: `docker compose --profile web up -d`
- For the tor web client: `docker compose --profile tor up -d`
- For materialious: `docker compose --profile materialious up -d`

# Run instructions (systemd)

First copy the invidious.service to /etc/systemd/system/

- For the database: `systemctl enable --now invidious@database.service`
- For the worker: `systemctl enable --now invidious@worker.service` 
- For the web client: `systemctl enable --now invidious@web.service`
- For the tor web client: `systemctl enable --now invidious@tor.service`
- For materialious: `systemctl enable --now invidious@materialious.service`

