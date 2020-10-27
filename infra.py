import click
import ansible_runner
from dotenv import load_dotenv
import docker
import os

def create_infrabuilder():
    ''' Create container image for IaC tools '''
    client = docker.from_env()
    client.images.build(path='infra-builder', tag='infrabuilder:rke')

def run_infrabuilder(workdir,command):
    ''' Execute command in infrabuilder container '''
    client = docker.from_env()
    client.containers.run('infrabuilder:rke', 
                            environment={'SSH_AUTH_SOCK':os.environ.get('SSH_AUTH_SOCK'),
                                        'TF_VAR_esxi_password':os.environ.get('TF_VAR_esxi_password')},
                            
                            command='env')

@click.group()
def cli():
  pass


@cli.command()
def create():
    click.echo('Creating Infrastructure')
    r = ansible_runner.run(private_data_dir='.', playbook='configure-project.yaml')
    create_infrabuilder()
    run_infrabuilder('hola', 'adios')
    # print("{}: {}".format(r.status, r.rc))
    # successful: 0
    # for each_host_event in r.events:
    #     print(each_host_event['event'])
    # print("Final status:")
    # print(r.stats)


@cli.command()
def destroy():
    click.echo('Destroying Infrastructure')


if __name__ == '__main__':
    load_dotenv()
    cli()
