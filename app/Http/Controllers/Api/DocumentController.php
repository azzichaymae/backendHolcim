<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Document;
use App\Models\EmployeeHabilitation;
use App\Models\Habilitation;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class DocumentController extends Controller
{
     //Get all documents for a specific employee habilitation
     public function getAllDocuments(): JsonResponse
{
     $user = auth()->user();

        if ($user->role === 'Manager') {
                  $serviceId = $user->service_id;
               $documents = Document::whereHas('employeeHabilitation.employee', function ($query) use ($serviceId) {
                    $query->where('service_id', $serviceId);
               })
               ->with('employeeHabilitation.employee', 'employeeHabilitation.habilitation')
               ->orderBy('created_at', 'desc')
               ->get()
               ->map(function ($doc) {
                    $doc->url = Storage::url($doc->chemin);
                    $doc->employee_nom = $doc->employeeHabilitation->employee->nom ?? null;
                    $doc->employee_prenom = $doc->employeeHabilitation->employee->prenom ?? null;
                    $doc->habilitation_nom = $doc->employeeHabilitation->habilitation->nom ?? null;
                    $doc->employee_matricule = $doc->employeeHabilitation->employee->matricule ?? null;
                    return $doc;
               });
    }else {
    $documents = Document::with('employeeHabilitation.employee', 'employeeHabilitation.habilitation')
    ->orderBy('created_at', 'desc')
    ->get()
    ->map(function ($doc) {
        $doc->url = Storage::url($doc->chemin);

        if ($doc->type === 'individuelle') {
            // For individuelle docs, use employeeHabilitation
            $doc->employee_nom = $doc->employeeHabilitation->employee->nom ?? null;
            $doc->employee_prenom = $doc->employeeHabilitation->employee->prenom ?? null;
            $doc->employee_matricule = $doc->employeeHabilitation->employee->matricule ?? null;
            $doc->habilitation_nom = $doc->employeeHabilitation->habilitation->nom ?? null;
        } elseif ($doc->type === 'note') {
            // For note docs, the foreign key points directly to habilitation
            $habilitation = Habilitation::find($doc->employee_habilitation_id); 
            $doc->habilitation_nom = $habilitation?->nom;
            // No employee info for notes
            $doc->employee_nom = null;
            $doc->employee_prenom = null;
            $doc->employee_matricule = null;
        }

        return $doc;
    });

    }
    return response()->json($documents, 200);
}

     // GET /api/documents?employee_habilitation_id=1
     public function index(Request $request): JsonResponse
     {
          $request->validate([
               'employee_habilitation_id' => 'required|exists:employee_habilitations,id',
          ]);

          $documents = Document::where('employee_habilitation_id', $request->employee_habilitation_id)
               ->orderBy('created_at', 'desc')
               ->get()
               ->map(function ($doc) {
                    $doc->url = Storage::url($doc->chemin);
                    return $doc;
               });

          return response()->json($documents, 200);
     }

     // POST /api/documents
     public function store(Request $request): JsonResponse
     {
          $request->validate([
               'employee_habilitation_id' => 'required|exists:employee_habilitations,id',
               'fichier' => 'required|file|mimes:pdf,jpg,jpeg,png|max:5120', // 5MB max
          ]);

          $file = $request->file('fichier');
          $extension = strtoupper($file->getClientOriginalExtension());
          $nom = $file->getClientOriginalName();

          // Generate unique filename to avoid collisions
          $filename = Str::uuid() . '.' . strtolower($extension);
          $chemin = $file->storeAs('habilitations/documents', $filename, 'public');

          $document = Document::create([
               'nom' => $nom,
               'chemin' => $chemin,
               'type' => $extension === 'JPEG' ? 'JPG' : $extension,
               'employee_habilitation_id' => $request->employee_habilitation_id,
          ]);

          $document->url = Storage::url($chemin);

          return response()->json($document, 201);
     }

     // GET /api/documents/{id}
     public function show(Document $document): JsonResponse
     {
          $document->url = Storage::url($document->chemin);
          $document->load('employeeHabilitation.employee');

          return response()->json($document, 200);
     }

     // DELETE /api/documents/{id}
     public function destroy(Document $document): JsonResponse
     {
          // Delete physical file from storage
          if (Storage::disk('public')->exists($document->chemin)) {
               Storage::disk('public')->delete($document->chemin);
          }

          $document->delete();

          return response()->json([
               'message' => 'Document supprimé avec succès.'
          ], 200);
     }

     // GET /api/documents/{id}/download
    public function download(Document $document)
{
    $fullPath = storage_path('app' . DIRECTORY_SEPARATOR . 'public' . DIRECTORY_SEPARATOR . $document->chemin);
    
    // Normalize slashes for Windows
    $fullPath = str_replace('/', DIRECTORY_SEPARATOR, $fullPath);

    if (!file_exists($fullPath)) {
        return response()->json([
            'message' => 'Fichier introuvable sur le serveur.',
            'path' => $fullPath,
        ], 404);
    }

    return response()->download($fullPath, $document->nom);
}

public function downloadByAttribution($employeeHabilitationId)
{
    $document = Document::where('employee_habilitation_id', $employeeHabilitationId)
        ->latest()
        ->first();

    if (!$document) {
        return response()->json(['message' => 'Aucun document trouvé pour cette attribution.'], 404);
    }

    $fullPath = str_replace('/', DIRECTORY_SEPARATOR, storage_path('app/public/' . $document->chemin));

    if (!file_exists($fullPath)) {
        return response()->json(['message' => 'Fichier introuvable sur le serveur.'], 404);
    }

    return response()->download($fullPath, $document->nom);
}
}