## Description

This package provides Python Virtualenv support for Atom users.

## Requirements

This package **works in UNIX and WINDOWS systems** :)

This package currently supports:

* A [virtualenvwrapper](https://pypi.python.org/pypi/virtualenvwrapper) installation
* Projects in your $HOME folder with virtualenvs inside it
* Environments in the root folder of you projects (ex: project1/env or project1/venv), so you can add the project paths manually in the additional virtual envs settings

## Usage

By default this plug-in is configured to use with a virtualenvwrapper and to get virtualenvs from the $HOME folder. But you can add specific virtualenvs paths too.

![settings](https://cloud.githubusercontent.com/assets/1611808/24892002/f3d69850-1e4f-11e7-835a-0dede75dd49c.png)

Commands:

* Activate a different environment (Virtualenv select)
* Create a new environment (Virtualenv make)
* Deactivate an environment (Virtualenv deactivate)

![Commands](https://cloud.githubusercontent.com/assets/1611808/21472334/671a0614-cabb-11e6-9b33-3ba1459ca072.png)

## To-Do List

 - [ ] Add support to use PIP to install new packages
 - [ ] Add support to use pip env

This project is on initial development. Feel free to contribute reporting bugs, improvements or creating pull requests.

## Disclaimer

Part of this code comes from [Jhutchins Project](https://github.com/jhutchins/virtualenv). I have created a new repository because jhutchins project is no longer maintained.
