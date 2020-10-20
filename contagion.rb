def set_global_parameters
    cl_args = capture_command_line_args

    $contagion_start_day = cl_args['contagion_start_day'] || 2
    $contagion_period = cl_args['contagion_period'] || 12

    $low_r_period = cl_args['low_r_period'] || 7
    $high_r_period = cl_args['high_r_period'] || 21
    $low_r = cl_args['low_r'] || 0.8
    $high_r = cl_args['high_r'] || 1.3
    $include_post_low_r_surge = cl_args['include_surge'] || false

    $peak_deaths = cl_args['peak_deaths'] || 24
    $deaths_spread = cl_args['deaths_spread'] || 3

    $deaths_scale_factor = cl_args['deaths_scale_factor'] || 0.05
end

$cadenced_cases = [1000]
$non_cadenced_cases = [1000]

def capture_command_line_args
    args = {}
    shortcuts = command_line_shortcuts
    for arg in ARGV
        parts = arg.split ':'
        if parts.count == 2
            parts[0] = shortcuts[parts[0]] || parts[0]
            if parts[1] == 'false' || parts[1] == 'true'
                args[parts[0]] = parts[1]
            else
                args[parts[0]] = parts[1].to_f
            end
        end
    end
    return args
end

def command_line_shortcuts
    shortcuts = {
        'csd' => 'contagion_start_day',
        'cp' => 'contagion_period',
        'lrp' => 'low_r_period',
        'hrp' => 'high_r_period',
        'lr' => 'low_r',
        'hr' => 'high_r',
        'is' => 'include_surge',
        'ps' => 'peak_deaths',
        'ds' => 'deaths_spread',
        'dsf' => 'deaths_scale_factor'
    }
    return shortcuts
end

def day_r day
    startup_period = 20
    return $high_r if day < startup_period
    day -= startup_period

    $include_post_low_r_surge ? day_r_with_post_low_r_surge( day ) : day_r_with_no_post_low_r_surge( day )
end

def day_r_with_no_post_low_r_surge day
    cycle_period = $low_r_period + $high_r_period
    in_period_day = day % cycle_period
    return $low_r if in_period_day < $low_r_period
    return $high_r
end

def day_r_with_post_low_r_surge day
    cycle_period = $low_r_period + $high_r_period
    in_period_day = day % cycle_period
    return $low_r if in_period_day < $low_r_period
    return surge_r if in_period_day > $low_r_period && in_period_day < 2 * $low_r_period
    return $high_r
end

def surge_r
    [$high_r * $high_r, 1.0 + ($high_r - 1.0) * 2].max    # For the latter, 1.3 goes to 1.6
end

def make_cases
    for d in 1..120
        r = day_r( d )
        todays_cadenced_cases = 0.0
        todays_non_cadenced_cases = 0.0
        for look_back in 1..$contagion_period
            infection_day = d - look_back - $contagion_start_day
            if infection_day >= 0
                todays_cadenced_cases += (r * $cadenced_cases[infection_day]) / $contagion_period
                todays_non_cadenced_cases += ($high_r * $non_cadenced_cases[infection_day]) / $contagion_period
            end
        end
        $cadenced_cases[d] = todays_cadenced_cases
        $non_cadenced_cases[d] = todays_non_cadenced_cases
    end
end

def deaths_from_cases cases
    deaths_per_day = []
    for day in 0...cases.count
        factor = 0.0
        factor_increment = $deaths_scale_factor
        for delay in ($peak_deaths - $deaths_spread)..$peak_deaths
            factor += factor_increment
            deaths_per_day[day+delay] = (deaths_per_day[day+delay] || 0) + factor * cases[day]
        end
        for delay in ($peak_deaths + 1)..($peak_deaths + $deaths_spread + 2)
            factor -= factor_increment
            if factor > 0.0
                deaths_per_day[day+delay] = (deaths_per_day[day+delay] || 0) + factor * cases[day]
            end
        end
    end
    return deaths_per_day
end

def output_results
    File.open( "contagion.txt", "wt" ) do |fout|
        (1...$cadenced_cases.count).each { |i| fout.puts "#{$non_cadenced_cases[i]}\t#{$cadenced_cases[i]}\t#{$non_cadenced_deaths[i]}\t#{$cadenced_deaths[i]}" }
    end
end

def output_settings
    File.open( "contagion-settings.txt", "wt" ) do |fout|
        settings = <<-SETTINGS_END
            contagion_start_day = #{$contagion_start_day}
            contagion_period = #{$contagion_period}

            low_r_period = #{$low_r_period}
            high_r_period = #{$high_r_period}
            low_r = #{$low_r}
            high_r = #{$high_r}
            include_post_low_r_surge = #{$include_post_low_r_surge}

            peak_deaths = #{$peak_deaths}
            deaths_spread = #{$deaths_spread}

            deaths_scale_factor = #{$deaths_scale_factor}
        SETTINGS_END
        settings.lines.each { |l| l.strip!; fout.puts l if ! l.empty? }
        fout.puts "\nratio of lives saved = #{death_factor}"
    end
end

def death_factor
    total_cadenced_deaths = $cadenced_deaths.reduce(0) { |sum,v| sum + (v || 0) }
    total_non_cadenced_deaths = $non_cadenced_deaths.reduce(0) { |sum,v| sum + (v || 0) }
    return total_non_cadenced_deaths / total_cadenced_deaths
end

set_global_parameters
make_cases
$cadenced_deaths = deaths_from_cases $cadenced_cases
$non_cadenced_deaths = deaths_from_cases $non_cadenced_cases
output_results
output_settings
