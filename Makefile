project=helloword
compose=docker run \
	--rm \
	-it \
	-v $(PWD):/src \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v /tmp:/tmp \
	-e "PATH_PROJECT=$(PWD)" \
	cedvan/compose:latest
host-web=helloword.dev


# HELP MENU
all: help
help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""
	@echo "   -- Installation"
	@echo ""
	@echo "   1.  make requirements         - Install requirements"
	@echo "   2.  make permissions          - Install permissions"
	@echo "   3.  make install              - Install project"
	@echo ""
	@echo "   -- Manage"
	@echo ""
	@echo "   1.  make update               - Update project"
	@echo "   2.  make start                - Start project"
	@echo "   3.  make stop                 - Stop project"
	@echo "   4.  make restart              - Stop and start project"
	@echo "   5.  make state                - State project"
	@echo ""
	@echo "   -- Tools"
	@echo ""
	@echo "   1.  make bash-php             - Launch bash PHP to project"
	@echo ""


# REQUIREMENTS
sudo-permissions:
	@echo "-------- Activate sudo mode : please enter your sudo password --------"
	@sudo echo "Sudo mode is activated"

install-docker:
	@echo "------------------------- Installing Docker --------------------------"
	@sudo apt-get update -q
	@sudo apt-get install -qy apt-transport-https curl
	@curl -sSL https://get.docker.com/ubuntu/ | sudo sh

requirements:
	@echo ""
	@echo "====================== Installing requirements ======================="
	@echo ""
	@make -s sudo-permissions
	@make -s install-docker
	@echo ""
	@echo "======== Requirements installing with success - Need REBOOT =========="

docker-permissions:
	@echo "--------------------- Adding docker permissions ----------------------"
	@sudo adduser `whoami` docker

permissions:
	@echo ""
	@echo "======================= Installing permissions ======================="
	@echo ""
	@make -s sudo-permissions
	@make -s docker-permissions
	@echo ""
	@echo "=============== Permissions installing with success =================="
	@echo ""


# MANAGE
pull:
	@echo "------------------------ Pulling docker images -----------------------"
	@$(compose) -p $(project) pull

start: up
restart: up
up:
	@echo "----------------------------- Starting -------------------------------"
	@$(compose) -p common up -d --no-recreate proxy
	@$(compose) -p $(project) up -d nginx
	@echo "------------------------- Application access -------------------------"
	@echo ""
	@echo "                      $(project)  :  $(host-web)"
	@echo ""


stop:
	@echo "----------------------------- Stopping -------------------------------"
	@$(compose) -p $(project) stop

state:
	@echo "--------------------------- Current state ----------------------------"
	@$(compose) -p $(project) ps

remove: stop
	@echo "----------------------------- Removing -------------------------------"
	@$(compose) -p $(project) rm --force

bash-php:
	@echo "----------------------------- Bash PHP -------------------------------"
	@$(compose) -p $(project) run --rm phpcli


# Installation and update
install:
	@echo ""
	@echo "============================ Installating ============================"
	@echo ""
	@make -s remove
	@make -s init
	@echo ""
	@echo "======================= installed with success ======================="
	@echo ""

update:
	@echo ""
	@echo "============================== Updating =============================="
	@echo ""
	@make -s stop
	@make -s init
	@echo ""
	@echo "======================== updated with success ========================"
	@echo ""

init:
	@make -s pull
	@make -s start
