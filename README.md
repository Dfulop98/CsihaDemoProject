
# Babilon

In this project, I automated a multi-step development and testing process within a specific technological environment. The system supports collaboration between developers, development team leaders, and testers, facilitating information flow through email notifications.

## Tech Stack
**SCM Server:** Gitlab  

**Containerization:** Docker  

**Scripts:** Bash, Powershell 

**Client:** .NET Core consoleApp   

**Server:** .NET Core consoleApp   

**Test Enviroment:** Nunit framework


## Installation with scripts

Open the cloned repository folder in Administration PowerShell. Administration mode is important.

First we need to give a perminission to run the setup script
```
    powershell.exe -ExecutionPolicy Bypass -File "setup.ps1"

```

During the next process your computer will restart a couple times.

After every restart, you need to run the same script again, and a setup process will continue from where its finished

#### Installation of required tools:
```
    .\setup.ps1
    
```
During the installation this happen:

### Setup script running process
####  Part 1/4
- Install Chocolately.
- Computer Restart.
#### Part 2/4
- Install OpenSSL.
- Create OpenSSL Certs.
- Install Docker Desktop.
- Update Wsl.
- Computer Restart.
#### Part 3/4
- Enabling Hyper-v & Containers.
- Computer restart.
#### Part 4/4
- Switch docker Deamon, if necesseries.
- Gitlab docker compose up
- Gitlab server reconfigure
- Docker container restart
- Options for generate ssh key.

After part 2, before run part 3, You'll need to login to Docker Desktop. If you don't have an account yet, you can register at the following link.

- [Docker Register](https://hub.docker.com/signup)

Now your gitlab server already reachable in https://[your local ip]:23443

Continue the setup process with "Gitlab Runners" section.
## Manual installation

### Clone the project

### Install Chocolately

You can install chocolately with a following command in PowerShell:
```
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    iex ((Invoke-WebRequest -Uri https://chocolatey.org/install.ps1).Content)
```
or you can follow the instruction from original documentation : https://chocolatey.org/install.

This installation requires a system restart.


### OpenSSL 
Because you already have Chocolately, you can simple install OpenSSL with it:
```
    choco install openssl -y
```
You will need to generate a proper certificate for validating the https connection.

First You need to create a config file ( examplesslcerts.cnf ). Where you predefine the ssl certification type.
The following documentation can be helpfully for the this process: https://www.openssl.org/docs/man1.1.1/man5/config.html

cnf file looks like this:

```
    [ req ]
    default_bits = 2048
    prompt = no
    default_md = sha256
    distinguished_name = dn
    req_extensions = req_ext

    [ dn ]
    C = {country first 2 letter}
    ST = {state}
    L = {city}
    O = {organization}
    OU = {oragnization name}
    emailAddress = {example@email.com}
    CN = {your ip}

    [ req_ext ]
    subjectAltName = @alt_names

    [ v3_req ]
    basicConstraints = CA:FALSE
    keyUsage = nonRepudiation, digitalSignature, keyEncipherment
    subjectAltName = @alt_names

    [ alt_names ]
    DNS.1 = {your ip}
    IP.1 = {your ip}

    [ v3_ca ]
    subjectAltName = @alt_names
    keyUsage = cRLSign, keyCertSign
    basicConstraints = CA:true
```

then run :
```
    openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout ../certs/[your ip].key -out ../certs/[your ip].crt -config [name of your config].cnf -extensions 'v3_req'
```
it will generate a new ssl certificate from the config file.

### Docker Desktop
#### Docker install
Install docker desktop with chocolately:
```
   choco install docker-desktop -y 
```
After this installation the device reboot is required.

#### Wsl update
After restart, if alert pop up with a warning "wsl version to low", run the following command
```
    wsl --update
```

#### Login or register Docker
If you already have docker account just login into, however you haven't yet, you can register in the following link: [Docker Hub](https://hub.docker.com/signup)

#### Enabling Hyper-V and container.
```
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
	Enable-WindowsOptionalFeature -Online -FeatureName Containers -All
```
Hyper-V is a virtualization solution that allows running virtual machines in a Windows environment. Containers is a service that enables the execution of Windows-based containers.

After this configuration change, unfortunatelly it is necessary to restart the computer again.


### Create Gitlab container, SSH key

In the following phrase, you need to create docker-compose.yml file, add external url, setup ssl certificates and add volumes


#### Docker compose build
Create docker-compose.yml file.
The compose file looks like this:
```
    version: "3.6"
    services:
    web:
        image: "gitlab/gitlab-ce:latest"
        container_name: gitlab-server
        command: /bin/bash -c "./allow_gitlab_ssl.sh && /assets/wrapper"
        restart: always
        environment:
        GITLAB_OMNIBUS_CONFIG: |
            external_url 'https://192.168.3.240'
            letsencrypt['enable'] = false
            nginx['redirect_http_to_https'] = false
            nginx['ssl_certificate'] = '/etc/gitlab/ssl/192.168.3.240.crt'
            nginx['ssl_certificate_key'] = '/etc/gitlab/ssl/192.168.3.240.key'

        ports:
        - "23080:80"
        - "23443:443"
        - "23022:22"
        volumes:
        - "gitlab_config:/etc/gitlab"
        - "gitlab_logs:/var/log/gitlab"
        - "gitlab_data:/var/opt/gitlab"
        - "../certs:/etc/gitlab/ssl"
        - "./allow_gitlab_ssl.sh:/allow_gitlab_ssl.sh"

        shm_size: "5gb"

    volumes:
    gitlab_config:
    gitlab_data:
    gitlab_logs:
    gitlab_certs:

```

#### Deamon switch to linux
Possible your Docker is running windows deamon at a moment, then you have to switch to linux:
```
    $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchDaemon
```

#### Gitlab Reconfigure
To make sure all configuration is saved, you need reconfigure the gitlab server, and restart the docker container also suggested:
```
    docker exec -it gitlab-server  gitlab-ctl reconfigure
    docker restart gitlab-server
```

#### Get initial root password:

Run the following command to get a root user password:
```
    docker exec -it gitlab-server cat /etc/gitlab/intial_root_password
```

#### Login into Gitlab with root user:

Now Gitlab server done to use. Go to https.[your local ip]:23443
```
    username: root
    password: (what you get in the previous task)
```
### Gitlab server settings
#### Edit root user:

After login, click your avatar in the left top corner, and Edit profile.
Below you'll see the main profile setting, setup the administrator account as you wish.

In the left sidebar you'll see a Password link, there you can change the root user password.

#### Setup SSH key

You'll need to generate ssh key to make accessable the repositories to your computer
```
    ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f ~/.ssh/{example}

```
this command will you run a generation process, and will give you some question, if you leave empty the password phrase, then the key will be stored without password.

After the generation process you'll need to copy the public key to gitlab.
```
    cat ~/.ssh/{given_name}.pub | xclip -selection clipboard

```

after these commands ,
- Login Gitlab,
- Click to the avatar in the left top corner 
- Settings
- SSH keys in left sidebar
- Copy your public key to the Key section
- Give a title, and press Add key button

Gitlab server default (port 22) for SSH, but we change 23022 trought the docker compose. Due to this, we need to make some additional configurations to connect successfully.

```
    $env:GIT_SSH_COMMAND = "ssh -i C:\Users\[username]\.ssh\[ssh keyname] -p 23022"

```
Once you're done with all these settings, you will have the permission to clone the GitLab repositories.

Now you successfully added a new SSH key, and now you can reach the Repositories
## Gitlab Runner Installation

While you need to connect gitlab server and gitlab runners, you'll need to create Docker network:
```
    docker network create gitlab_network
```
The other setting already done in the compose files.

After you created a network, you'll have to generate Tokens for the runners.
- Gitlab project created:
- Left sidebar settings
- CI/CD
- Runners expand
- New project runner
- Give tags, description and create runner


## Smtp Service
## Run Locally

Clone the project

```bash
  git clone https://link-to-project
```

Go to the project directory

```bash
  cd my-project
```

Install dependencies

```bash
  npm install
```

Start the server

```bash
  npm run start
```


## Deployment

To deploy this project run

```bash
  npm run deploy
```


## Optimizations

What optimizations did you make in your code? E.g. refactors, performance improvements, accessibility


## Lessons Learned

What did you learn while building this project? What challenges did you face and how did you overcome them?


## Documentation

 - [Gitlab Docs](https://docs.gitlab.com/)
 - [Docker Docs](https://docs.docker.com/)
 - [Twillio Sendgrid](https://app.sendgrid.com/login?redirect_to=%2F)

## Screenshots

![App Screenshot](https://via.placeholder.com/468x300?text=App+Screenshot+Here)


## Usage/Examples

```javascript
import Component from 'my-project'

function App() {
  return <Component />
}
```


## Roadmap

- Additional browser support

- Add more integrations

