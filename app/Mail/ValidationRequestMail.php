<?php
namespace App\Mail;

use App\Models\AttributionValidation;
use App\Models\EmployeeHabilitation;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Mail\Mailables\Content;

class ValidationRequestMail extends Mailable
{
    public function __construct(
        public AttributionValidation $validation,
        public EmployeeHabilitation  $eh,
    ) {}

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'Demande de validation — ' . $this->eh->habilitation->nom .
                     ' — ' . $this->eh->employee->prenom . ' ' . $this->eh->employee->nom,
        );
    }

    public function content(): Content
    {
        return new Content(
            view: 'emails.validation-request',
        );
    }
}