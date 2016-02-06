import os
import sys, getopt
from pprint import pprint
import ConfigParser
import argparse

def init_config(filename="/etc/php5/fpm/pool.d/www.conf"):
    Config = ConfigParser.ConfigParser()
    Config.read(filename)
    return Config


def rename_section(filename="/etc/php5/fpm/pool.d/www.conf", existing_name="www", new_name=None):
    """
    Renames a configuraiton section.

    Does so by actually copying all config items to a new section, then removing the original section.

    :param filename: the path to the file to be editied
    :param existing_name: the existing section name
    :param new_name: the new section name
    """
    Config = ConfigParser.ConfigParser()
    Config.read(filename)
    section_items = Config.items(existing_name)
    for item in section_items:
        _opt_move(Config
                  , section1=existing_name
                  , section2=new_name
                  , option=item)
    Config.remove_section(existing_name)

    with open(filename, 'wb') as configfile:
        Config.write(configfile)


def _opt_move(config, section1, section2, option):
    """
    Helper function for moving an existing option from one section to another.

    :type section2: str
    :type section1: str
    :type config: object
    :type option: tuple
    :param config: an config object
    :param section1: name of the original section
    :param section2: name of the new section
    :param option: a tuple of the configuration option (name,value)
    
    """
    try:
        config.set(section2, option[0], config.get(section1, option[0]))
    except ConfigParser.NoSectionError:
        # Create non-existent section
        config.add_section(section2)
        _opt_move(config, section1, section2, option)
    else:
        config.remove_option(section1, option[0])


def envs_to_configs(filename="/etc/php5/fpm/pool.d/www.conf", sectionname="www", prefix="wp"):
    """
    Converts environment variables into php-fpm variables.

    Writes or updates them to the specified file (should be a pool file).
    :type prefix: str
    :type sectionname: str
    :type filename: str
    :param filename: The filename to write to.
    :param sectionname: The sectionname to write to.
    :param prefix: the prefix to filter environment variables.
    """

    # env[MY_VAR]
    variable_list = get_vars(prefix=prefix)
    theconfig = init_config(filename=filename)
    for variable in variable_list:
        thename = "env[{0}]".format(variable.get("key"))
        thevalue = variable.get("val")
        output = "env[{0}] = {1}".format(thename,thevalue)
        print(output)
        write_to_conf(theconfig,sectionname=sectionname,option=thename,value=thevalue)

    with open(filename, 'wb') as configfile:
        theconfig.write(configfile)


def write_to_conf(configObj,sectionname="www",option=None,value=None):
    Config = configObj
    try:
        Config.set(section=sectionname,option=option,value=value)
    except ConfigParser.NoSectionError as e:
        Config.add_section(sectionname)

def get_vars(varname=None,prefix=None):
    """
    Retrieves all environment variables on the system and returns them as a list of dictionaries.

    :type prefix: str
    :rtype: list
    :param prefix: THe prefix to filter for.
    :return: A list of environment variables which are a dictionaries with "name" and "value" keys.
    """
    if varname:
        thevar = os.environ.get(varname)
        return thevar
    variables_to_show = sorted(os.environ.keys())
    envarlist = list()
    for index, variable in enumerate(variables_to_show):
        if prefix in variable:
            value = os.environ.get(variable)
            envvar = dict(
                    key=variable,
                    val=value
            )
            envarlist.append(envvar)
    return envarlist

def do_config(appname=None):
    """
    Sets up wp the php-fpm environment.

    Requestes one commandline parameters, env_prefix.
    * env_prefix is the prefix of enviroment variables that we want to convert to php-fpm env varialbes.

    The app name is set from an environment variable called "app_name", which should be set when the container is run.
    This will change the name of the fpm process to be the name of the app so that it is easier to track in ps and top.

    :param appname:
    """
    app_name = get_vars(varname="app_name")
    arguments = sys.argv
    if len(arguments) != 2:
        raise AttributeError("You must specify --env_prefix")
        sys.exit(status=1)
    parsedoptlist = list()
    for arg in arguments:
        if "--" in arg:
            full = arg.split("--")[1].split("=")
            option = full[0]
            thevalue = full[1]
            parsedopt = (option,thevalue)
            if option in ("env_prefix"):
                parsedoptlist.append(parsedopt)
    if len(parsedoptlist) != 1:
        raise AttributeError("You must specify --env_prefix")
        sys.exit(1)
    for arg in parsedoptlist:
        if arg[0] == "env_prefix":
            env_prefix = arg[1]
    envs_to_configs(prefix=env_prefix)
    rename_section(new_name=app_name)

if __name__ == "__main__":
    do_config()
