module SumStats;

export {
        redef enum Calculation += { COUNTTABLE };

        redef record ResultVal += {
            counttable: table[string] of count &optional;
        };
}

function add_ct_entry(mytable: table[string] of count, str: string, num: count)
{
    if ( str !in mytable )
    {    
        mytable[str] = 0;
    }
    mytable[str] += num;
}

hook register_observe_plugins()
{
    register_observe_plugin(COUNTTABLE, function(r: Reducer, val: double, obs: Observation, rv: ResultVal)
    {
        # observations for us always need a string and a num. Otherwhise - complain.
        if ( ! obs?$str )
        {
            Reporter::error("COUNTTABLE sumstats plugin needs str in observation");
            return;
        }

        local increment = 1;
        if ( obs?$num )
        {
            increment = obs$num;
        }
        if ( ! rv?$counttable )
        {
            rv$counttable = table();
        }
        add_ct_entry(rv$counttable, obs$str, increment);
    });
}

hook compose_resultvals_hook(result: ResultVal, rv1: ResultVal, rv2: ResultVal)
{
    if ( ! (rv1?$counttable || rv2?$counttable ) )
    {
        return;
    }
    if ( !rv1?$counttable )
    {
        result$counttable = copy(rv2$counttable);
        return;
    }

    if ( !rv2?$counttable )
    {
        result$counttable = copy(rv1$counttable);
        return;
    }

    result$counttable = copy(rv1$counttable);

    for ( i in rv2$counttable )
    {
        add_ct_entry(result$counttable, i, rv2$counttable[i]);
    }
}

