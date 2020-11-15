import click
import ansible_runner
from dotenv import load_dotenv
import docker
import os
import shutil
import subprocess
import threading

def read_config():
    import yaml
    with open('project/vars.yaml', 'r') as f:
        config_file = yaml.load(f, Loader=yaml.FullLoader)
    return config_file

def start_webserver(webserver_port):
    import http.server
    import functools
    import socketserver
    Handler = functools.partial(http.server.SimpleHTTPRequestHandler, directory='cloud-init')
    with socketserver.TCPServer(("", webserver_port), Handler) as httpd:
        print("serving at port", webserver_port)
        httpd.serve_forever()

@click.group()
def cli():
  pass


@cli.command()
def create():
    click.echo('Creating Infrastructure')
    config = read_config()
    esxi_server = config['esxi']['ipaddr']
    webserver_ip = config['webserver_ip']
    webserver_port = int(config['webserver_port'])

    r = ansible_runner.run(private_data_dir='.', playbook='configure-project.yaml')

    r = subprocess.run(["terraform", "init"], cwd='/files/terraform')
    r = subprocess.run(["terraform", "apply", "-auto-approve"], cwd='/files/terraform')

    webserver = threading.Thread(target=start_webserver, args=(webserver_port,))
    webserver.start()

    r = ansible_runner.run(private_data_dir='.', playbook='attach-iso-to-vm.yaml')

    vmid = subprocess.run(["ssh", "root@" + esxi_server, "vim-cmd vmsvc/getallvms | grep rke-controlplane-1 | cut -f1 -d ' '"], capture_output=True, universal_newlines=True)    
    vmid = str(vmid.stdout).rstrip()
    print(f'http://{esxi_server}/ui/#/console/{vmid}')
    print('\nBoot VM and go into advanced boot options by pressing <TAB>\n')
    print('Add the following options and hit <ENTER>')
    print(f'autoinstall ds=nocloud-net;s=http://{webserver_ip}:{webserver_port}/\n')

    pause = input('Press <ENTER> after the VM has been fully installed')
    r = ansible_runner.run(private_data_dir='.', playbook='resize-filesystem.yaml')


@cli.command()
def destroy():
    click.echo('Destroying Infrastructure')
    result = subprocess.run(["terraform", "destroy", "-auto-approve"], cwd='/files/terraform')

    for directory in ["cloud-init", "artifacts", "inventory", "terraform"]:
        shutil.rmtree(directory)
        pass


if __name__ == '__main__':
    load_dotenv()
    read_config()
    cli()
