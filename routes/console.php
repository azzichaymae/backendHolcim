<?php

use Illuminate\Support\Facades\Schedule;
use App\Console\Commands\UpdateStatutsExpires;
use App\Console\Commands\GenererAlertes;

Schedule::command(UpdateStatutsExpires::class)->dailyAt('00:00');
Schedule::command(GenererAlertes::class)->dailyAt('00:05');