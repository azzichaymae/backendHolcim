<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

\DB::listen(function ($query) {
    \Log::info('SQL: ' . $query->sql . ' | Time: ' . $query->time . 'ms');
});
class CheckRole
{
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        if (!$request->user()) {
            return response()->json([
                'message' => 'Non authentifié.'
            ], 401);
        }

        if (!in_array($request->user()->role, $roles)) {
            return response()->json([
                'message' => 'Accès refusé. Permission insuffisante.',
                'role_requis' => $roles,
                'votre_role'  => $request->user()->role,
            ], 403);
        }

        return $next($request);
    }
    
}