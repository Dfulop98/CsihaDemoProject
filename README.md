
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

A GitLab Runner is a tool that executes jobs in GitLab CI/CD pipelines, allowing automated testing and deployment. It's essential for streamlining the development process and ensuring efficient code integration.

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

After creating a gitlab runner, platform will give you an information about a runner.(how to regist, token)

You can following the instructions, what the platform give to you, or in a setup folder you'll find docker-compose.runners.yml. These runners was created to my demo project, so the gitlab runner tokens are already defined, but you can see how this configuration has to be looks like.

Cuz, we run gitlab server in docker network, suggested to make a runners in the same network. (best practice if you make compose for them)
## Add Gitlab users

If you wish to add a new user to our GitLab system without them having an existing account, follow these steps:
- Log into your GitLab system as an administrator.
- In the main menu, select the "Admin Area" option.
- Within the Admin Area's sidebar, click on the "Users" option.
- From here, click on the "New User" button.
- Fill out the necessary information to create the user, such as their email address, password, and other related details.
- Once completed, click the "Create User" button.

By doing so, you've created a new user account without the user having an existing GitLab account. You can now add this user to projects or groups within the system.
# Demo Project reproducate

- First add users: 
Left side in the sidebar:

Admin area > Users : Here you can add a new users without a real profile behind them.
- Create Group called demo
- Create Babilon Project
- In the starting repo you'll see the instruction to inject the source code with pipeline into it.
- Next you need create a gitlab runners for the pipeline. Demo > Babilon > Settings > CI/CD (Sidebar)
- Now you have to create a branches and make them protected : Setting > Protected branches
- Add users to the project, with proper role: Demo > Babilon > Group > Members 
- With the project_source code which is include the pipeline and with these setting your gitlab will working kinda simillar then mine. However have some step which i did mention in other sections, like ssh key setup.
# Run demo project
Unfortunately, due to the use of Windows, some Docker images have become quite large in size. The installation process is simple, but it requires a bit of patience

Go to babilon_demo folder, simple run:
```
    docker-compose up -d
```
This command will pull the project created by the test task from Docker Hub as an image and will start the runners set up for it. I've attached the login details in a private email, but those with expertise can log in without them.

I wrote a script for the test task's settings and data, which is already contained in the running Docker container, so all you need to do is execute the following command:
```
    docker exec -it babilon-demo /restore.sh
```

After the test process is completed, the GitLab server can be accessed at the web address https://localhost:23443

user: root

password: 93380061

( I have issue with this part, unfortunatelly if i try to restore, the database somehow couse error, and a CI/CD settings pages not available. I still documenting this section but cannot recover the task project with it. Its really unusual reproducate the gitlab server with backup transfer, without teraform or any osc service, but these are make more complexity )
## Gitlab Backup
To ensure the project can be quickly and easily initiated on another system, a backup must be made from the GitLab server, which will then be restored on the other device.

For this, we need to run the following commands:
```
    docker exec -t <container name> gitlab-backup create STRATEGY=copy
```

## Gitlab Restore

First you need copy backup.tar back to the gitlab docker.
```
    docker cp ./backups/backups/1691990441_2023_08_14_16.2.3_gitlab_backup.tar [container_id]:/var/opt/gitlab/backups/
```

Then, stop all gitlab service:
```
    docker exec -it [container_id] gitlab-ctl stop unicorn
    docker exec -it [container_id] gitlab-ctl stop puma
    docker exec -it [container_id] gitlab-ctl stop sidekiq 
```

now, run restore command:
```
    docker exec -it [container_id] gitlab-backup restore BACKUP=1691990441_2023_08_14_16.2.3
```

Copy back, the config, and secret file:
```
    docker cp ./backups/gitlab.rb [container_id]:/etc/gitlab/
    docker cp ./backups/gitlab-secrets.json [container_id]:/etc/gitlab
```
And finally restart , reconfigure the server:
```
    docker exec -it [container_id] gitlab-ctl start unicorn
    docker exec -it [container_id] gitlab-ctl start puma
    docker exec -it [container_id] gitlab-ctl start sidekiq 
    docker exec -it [container_id] gitlab-ctl reconfigure
    docker exec -it [container_id] gitlab-ctl restart
    docker exec -it [container_id] gitlab-rake gitlab:check SANITIZE=true
```
## Documentation

 - [Gitlab Docs](https://docs.gitlab.com/)
 - [Docker Docs](https://docs.docker.com/)
 - [Twillio Sendgrid](https://app.sendgrid.com/login?redirect_to=%2F)

## Lessons Learned

I would talk about these parts more detailed in face to face.

I primarily trained myself to be a C# backend developer, so this task and many of the technologies used were quite new to me. I tried my best to research the necessary things I wasn't familiar with.

Firstly, I would mention the GitLab server. I had previous experience with Git systems and regularly use GitHub for code sharing. However, GitLab itself was unknown to me until now. Despite this, it's quite user-friendly, and the full installation and configuration of GitLab on a Linux system didn't take even a day.

The completion of the project code and the pipeline processes, scripts, were not unfamiliar to me. I didn't face major challenges at this part. It was the GitLab runner that I had to look more into. However, I did not fully utilize the opportunities offered by SendGrid for sending emails and the transparency provided by the GitLab server. To keep it simple, I send emails using a basic curl script through an API.

I had the idea to make the project launchable via docker-compose, allowing me to test the same project I worked on on another device. However, since I didn't have an extensive knowledge of Docker, I didn't realize that it wasn't that simple, and my approach might not be the most appropriate. I recognized that the Docker image I was using wouldn't include the modifications made on the GitLab server upon commit since the image inherently uses a locally created volume for these backups. After discovering this issue during final testing on a different computer, I quickly delved into other alternatives. I tried creating backups and restoring them, which was the closest solution I found so far. Unfortunately, due to database errors, the CI/CD settings page is not accessible on the user interface. I tried using storage containers made from an Alpine image, but unfortunately, this also did not lead to a solution. This was the critical part of the task that caused me to fall behind, and it's why I'm now making these minor adjustments.

In retrospect, looking over the project, during the installation scripts, for some inexplicable reason, I tried to merge the local IP with the GitLab server URL, which is completely unnecessary since the server will already be accessible on localhost. During the docker-compose process, I use an external network for the communication between the GitLab server and the runners, which is also a redundant step since they can already communicate on an internal network.

It was a truly enlightening and interesting task. I learned a lot from it, and now, in hindsight, I would approach it completely differently.
