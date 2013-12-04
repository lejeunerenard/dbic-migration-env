# Copyright (c) 2013 Sean Zellmer @lejeunerenard under GPLv2

export DBICM_BEFORE_PERL5LIB=$PERL5LIB

_dbicm_env() {
   # Find config file
   # @TODO Should be allow yml files in environments
   local config_file="${_DBICM_CONFIG:-$*/environments/development.yml}"
   local lib_add="${_DBICM_LIB_DIRS:-$*/lib:$*/local/lib/perl5}"

   # bail if we don't own the config file (we're another user but our ENV is still set)
   [ ! -f "$config_file" ] && return
   [ -f "$config_file" -a ! -O "$config_file" ] && return

   DSN=$(grep "schema_class:" $config_file | sed 's/^\s*//g' | awk '{print $2}')

   if [ "$DBIC_MIGRATION_SCHEMA_CLASS" != "$DSN" ]
   then
      export PERL5LIB="$DBICM_BEFORE_PERL5LIB:$lib_add"
      export DBIC_MIGRATION_SCHEMA_CLASS=$DSN
   else
      if [ ! "$DBIC_MIGRATION_SCHEMA_CLASS" ]
      then
         export PERL5LIB="$DBICM_BEFORE_PERL5LIB"
      fi
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
    #complete -o filenames -C '_z --complete "$COMP_LINE"' ${_DBICM_ENV_CMD:-dbicm-env}
     # populate directory list. avoid clobbering other PROMPT_COMMANDs.
     grep "_dbicm_env" <<< "$PROMPT_COMMAND" >/dev/null || {
         PROMPT_COMMAND="$PROMPT_COMMAND"$'\n''_dbicm_env "$(pwd 2>/dev/null)" 2>/dev/null;'
     }
fi
