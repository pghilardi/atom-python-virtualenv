## Description

This package provides Python Virtualenv support for Atom users.

## Requirements

This package **only works in UNIX systems**. It does not work in Windows.

This package currently supports two types of setup:

* A [virtualenvwrapper](https://pypi.python.org/pypi/virtualenvwrapper) installation
* Environments in the root folder of you project

## Usage

By default this plug-in is configured to use with a virtualenvwrapper. But if your virtual envs are inside the HOME folder of your username you can just check  a configuration option on Settings: 

![settings](https://cloud.githubusercontent.com/assets/1611808/24335317/3387d064-1251-11e7-9233-83c99796b5a9.png)

Commands:

* Activate a different environment (Virtualenv select)
* Create a new environment (Virtualenv make)
* Deactivate an environment (Virtualenv deactivate)

![Commands](https://cloud.githubusercontent.com/assets/1611808/21472334/671a0614-cabb-11e6-9b33-3ba1459ca072.png)

## To-Do List

 - [ ] Add support to Windows
 - [ ] Add support to show the current virtualenv in the status bar
 - [ ] Add support to use PIP to install new packages

This project is on initial development. Feel free to contribute reporting bugs, improvements or creating pull requests.

## Disclaimer

Part of this code comes from [Jhutchins Project](https://github.com/jhutchins/virtualenv). I have created a new repository because jhutchins project is no longer maintained.
