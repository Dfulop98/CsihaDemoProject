
# Babilon

In this project, I automated a multi-step development and testing process within a specific technological environment. The system supports collaboration between developers, development team leaders, and testers, facilitating information flow through email notifications.

## Tech Stack
**SCM Server:** Gitlab  

**Containerization:** Docker  

**Scripts:** Bash, Powershell 

**Client:** .NET Core consoleApp   

**Server:** .NET Core consoleApp   

**Test Enviroment:** Nunit framework


## PowerShell settings

To run the installation scripts, we will first need to grant permission to PowerShell to execute these processes.

Launch PowerShell in administrator mode:

```pwsh
  Set-ExecutionPolicy Unrestricted -Scope Process
```

This command enables the execution of scripts for the next process. It is generally not advisable to turn this on, as there is nothing to prevent the execution of malicious scripts of unknown origin.
## Installation

#### Clone the project

```pwsh
  git clone https://github.com/Dfulop98/CsihaDemoProject
```

- Open the folder in PowerShell

#### Installation of required tools:
```
    cd PATH_TO_THE_PROJECT/install-requirements

    .\install_requirements.ps1
```
During the installation, we first obtain the Choco installation tool. Using this tool, we install Docker Desktop and Docker CLI so that we can run the GitLab server in a container.

After this installation process, it is necessary to restart the computer to continue.

#### Enabling Hyper-V and container.
```
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
	Enable-WindowsOptionalFeature -Online -FeatureName Containers -All
```
Hyper-V is a virtualization solution that allows running virtual machines in a Windows environment. Containers is a service that enables the execution of Windows-based containers.

After this configuration change, unfortunatelly it is necessary to restart the computer again.

#### Login or register Docker
If you already have docker account just login into, however you haven't yet, you can register in the following link: [Docker Hub](https://hub.docker.com/signup)

#### Create Gitlab container, SSL certs 
```
    cd PATH_TO_THE_PROJECT/create-gitlab
    .\create_gitlab_container.ps1
```
This script, with the help of openssl and the predefined sslcert.cnf, generates the files required for authentication. After that, it runs the docker-compose yaml file found in the folder.

If necessary, it switches the Docker daemon to manage Linux containers instead of Windows containers.

The last part of the script launches the docker-compose yaml file. In the docker-compose yaml file, the newly generated SSL authentication is set up, along with the access paths.

After the installation, you will need to wait a few minutes before the GitLab server becomes available at the following address:
```
    https://{your_local_ip}:23443
```
#### Gitlab Reconfigure
To make sure all configuration is saved, you need reconfigure the gitlab server, and restart the docker container also suggested
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

Now Gitlab server done to use. Go to https.{your_local_ip}:23443
```
    username: root
    password: (what you get in the previous task)
```

#### Edit root user:

After login, click your avatar in the left top corner, and Edit profile.
Below you'll see the main profile setting, setup the administrator account as you wish.

In the left sidebar you'll see a Password link, there you can change the root user password.

## Create Group and Project

After a gitlab installation process
## Gitlab Runners
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

