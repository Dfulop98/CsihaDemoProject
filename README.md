# CsihaDemoProject

1. create ssl certs:

	-Run Pwsh in administration mode
	-Allow to pwsh to run external scripts only in this session:
	"""
	Set-ExecutionPolicy Unrestricted -Scope Process

	"""
	run:
	-./create_self_signed_ssl.ps1 in gitlab-server-setup folder
	
	or just:
	
	"Get-Content ./create_self_signed_cert.ps1 | Invoke-Expression"
2. Setup Docker
	
	run : 
	./setup_docker
	if you havent docker, it will install and set it up
	and last change to the proper management and run gitlab server

-docker run --detach --publish 443:443 --publish 80:80 --publish 1001:22 --name gitlab --restart always --volume gitlab_config:/etc/gitlab --volume gitlab_logs:/var/log/gitlab --volume gitlab_data:/var/opt/gitlab --shm-size 5gb gitlab/gitlab-ce:latest