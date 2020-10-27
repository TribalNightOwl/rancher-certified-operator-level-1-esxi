import click
import ansible_runner
from dotenv import load_dotenv
import docker
import os
import shutil

@click.group()
def cli():
  pass


@cli.command()
def create():
    click.echo('Creating Infrastructure')
    r = ansible_runner.run(private_data_dir='.', playbook='configure-project.yaml')
    # print("{}: {}".format(r.status, r.rc))
    # successful: 0
    # for each_host_event in r.events:
    #     print(each_host_event['event'])
    # print("Final status:")
    # print(r.stats)


@cli.command()
def destroy():
    click.echo('Destroying Infrastructure')
    for directory in ["cloud-init", "artifacts", "inventory", "terraform"]:
        shutil.rmtree(directory)
        pass

    



if __name__ == '__main__':
    load_dotenv()
    cli()
