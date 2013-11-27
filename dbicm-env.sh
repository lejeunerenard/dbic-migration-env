# Copyright (c) 2013 Sean Zellmer @lejeunerenard under GPLv2

_dbicm_env() {
   # Find config file
   # @TODO Should be allow yml files in environments
   local config_file="${_DBICM_CONFIG:-$*/config.yml}"

   echo "\$* : "$*;
   echo "config_file: "$config_file;

   # bail if we don't own the config file (we're another user but our ENV is still set)
   [ -f "$config_file" -a ! -O "$config_file" ] && return

   if [ $DBIC_MIGRATION_SCHEMA_CLASS ]
   then
      echo "DBIC_MIGRATION_SCHEMA_CLASS Found"
   else
   fi
}

alias ${_DBICM_ENV_CMD:-dbicm-envz}='_dbicm_env 2>&1'

if compctl >/dev/null 2>&1; then
    # zsh
    # populate directory list, avoid clobbering any other precmds.
    _dbicm_env_precmd() {
       _dbicm_env "${PWD:A}"
    }
    [[ -n "${precmd_functions[(r)_dbicm_env_precmd]}" ]] || {
        precmd_functions+=(_dbicm_env_precmd)
    }
elif complete >/dev/null 2>&1; then
    # bash
    # tab completion
    complete -o filenames -C '_z --complete "$COMP_LINE"' ${_DBICM_ENV_CMD:-dbicm-env}
    [ "$_Z_NO_PROMPT_COMMAND" ] || {
        # populate directory list. avoid clobbering other PROMPT_COMMANDs.
        grep "_z --add" <<< "$PROMPT_COMMAND" >/dev/null || {
            PROMPT_COMMAND="$PROMPT_COMMAND"$'\n''_z --add "$(pwd '$_Z_RESOLVE_SYMLINKS' 2>/dev/null)" 2>/dev/null;'
        }
    }
fi
