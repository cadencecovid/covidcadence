# The case for Cadence lockdowns to tackle Covid spread

This site explores the potential for Cadence lockdowns to control the spread
of the Covid virus without significantly damaging the economy and people's
wellbeing.

Cadence lockdowns involve, for example, a strong 1 week lockdown followed
by, say, 3 weeks of lighter restrictions.  This cycle is repeated until
the seasons change, a vaccine is developed, herd immunity develops or the
virus mutates into a less virulent form.

A quickly put together paper describing this concept in more detail is
available at: [https://raw.githubusercontent.com/cadencecovid/covidcadence/main/Cadence-Lockdowns.pdf](https://raw.githubusercontent.com/cadencecovid/covidcadence/main/Cadence-Lockdowns.pdf).

Central to the investigation is a Ruby program called `contagion.rb` that is used to model different lockdown scenarios and so establish the benefits of Cadence lockdowns. This is described further below.

## contagion.rb

`contagion.rb` is the model simulation program. This section describes how you use the program.

### Setting parameter

To override the defaults, the program takes parameters of the form:

```
<parameter name>:<parameter value>
```

Parameters have both long and short names.  The short names are typically the initial letter fo the words making up the long parameter name.

To run the program with a high R period of 52 days you would run the following:

```
contagion.rb  high_r_period:52
```

or:

```
contagion.rb  hrp:52
```

The program supports the following parameters:

| Long parameter name | Short name | Default | Description |
|-|-|-|-|
| contagion_start_day | csd | 2 | How long before soemone is contagious after infection - in days |
| contagion_period | cp | 12 | How long someone remains contagions after becoming contagious - in days |
| low_r_period | lrp | 7 | The number of days for the low R period |
| high_r_period | hrp | 21 | The number of days for the high R period |
| low_r | lr | 0.8 | The low R value |
| high_r | hr | 1.3 | The high R value |
| include_surge | is | false |  |
| peak_deaths | pd | 24 | Number of days after infection that most patients die |
| deaths_spread | ds | 3 | Number of days before and after peak deaths day over which patients die |
| deaths_scale_factor | dsf | 0.05 | A fudge factor to get the cases and deaths displayable on the same graph |

### The output

The program generates 4 columns of numbers to a file called `contagion.txt`.

The first column is the number of Covid cases without any additional lockdown measures, with one number for each consecutive day.

The second column is the number of Covid cases with Cadence lockdowns in place for each day.

The third column is the number of deaths without additional lockdown measures for each day.

The fourth column is the number of deaths with Cadence lockdowns in effect for each day.

*Note that* the absolute values of the numbers is not significant. It is only their value relative to the numbers in their neighbouring column that is significant.  Suitable scale factors (one for cases and one for deaths) would have to be applied to the output numbers in order for them to mirror the actual cases and deaths in a real population.  (It is for this reason that any graphs in the report are shown without a vertical scale.)

The program also outputs the settings for the simulation in the file called `contagion-settings.txt`.
