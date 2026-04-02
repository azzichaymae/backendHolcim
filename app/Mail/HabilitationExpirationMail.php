<?php

namespace App\Mail;

use App\Models\EmployeeHabilitation;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class HabilitationExpirationMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(
        public EmployeeHabilitation $eh,
        public int $joursAvant,
    ) {}

    public function envelope(): Envelope
    {
        $subject = match(true) {
            $this->joursAvant === 0  => '🚩',
            $this->joursAvant <= 7   => '🚩',
            default                  => '⚠️',
        };

       return new Envelope(
        subject: $subject . 'Alerte : ' . $this->eh->habilitation->nom . ' — ' . 
                 ($this->joursAvant === 0 ? 'Expiré aujourd\'hui' : 'Expire dans ' . $this->joursAvant . 'j'),
    );
    }

    public function content(): Content
    {
        return new Content(
            view: 'emails.habilitation_expiration',
        );
    }
}