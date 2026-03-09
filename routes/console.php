<?php

use Illuminate\Support\Facades\Schedule;
use App\Console\Commands\UpdateStatutsExpires;
use App\Console\Commands\GenererAlertes;

Schedule::command(UpdateStatutsExpires::class)->dailyAt('00:00');
Schedule::command(GenererAlertes::class)->dailyAt('00:05');
Schedule::command('alertes:envoyer-mail')->dailyAt('08:00');



use Illuminate\Support\Facades\Artisan;
use Mailtrap\Helper\ResponseHelper;
use Mailtrap\MailtrapClient;
use Mailtrap\Mime\MailtrapEmail;
use Symfony\Component\Mime\Address;

Artisan::command('send-mail', function () {
    $email = (new MailtrapEmail())
        ->from(new Address('hello@demomailtrap.co', 'Mailtrap Test'))
        ->to(new Address('azzichaimae710@hotmail.com'))
        ->subject('You are awesome!')
        ->category('Integration Test')
        ->text('Congrats for sending test email with Mailtrap!')
    ;

    $response = MailtrapClient::initSendingEmails(
        apiKey: '<YOUR_API_TOKEN>'
    )->send($email);

    var_dump(ResponseHelper::toArray($response));
})->purpose('Send Mail');