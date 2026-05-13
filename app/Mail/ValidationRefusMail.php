<?php

namespace App\Mail;

use App\Models\AttributionValidation;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Mail\Mailables\Content;

class ValidationRefusMail extends Mailable
{
    public function __construct(
        public AttributionValidation $validation,
    ) {}

    public function envelope(): Envelope
    {
        $eh = $this->validation->employeeHabilitation;
        return new Envelope(
            subject: 'Refus de validation — ' . $eh->habilitation->nom .
                     ' — ' . $eh->employee->prenom . ' ' . $eh->employee->nom,
        );
    }

    public function content(): Content
    {
        return new Content(
            view: 'emails.validation-refus',
        );
    }
}