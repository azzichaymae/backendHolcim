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
            $this->joursAvant === 0  => '🔴 Habilitation expirée aujourd\'hui — ' . $this->eh->habilitation->nom,
            $this->joursAvant <= 7   => '🟠 Habilitation expire dans ' . $this->joursAvant . ' jours — ' . $this->eh->habilitation->nom,
            default                  => '🟡 Habilitation expire dans ' . $this->joursAvant . ' jours — ' . $this->eh->habilitation->nom,
        };

        return new Envelope(subject: $subject);
    }

    public function content(): Content
    {
        return new Content(
            view: 'emails.habilitation_expiration',
        );
    }
}