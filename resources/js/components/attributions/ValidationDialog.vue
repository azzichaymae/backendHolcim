<template>
  <v-dialog v-model="dialog" max-width="480" scrollable>
    <v-card rounded="lg" elevation="0" border>

      <v-card-title class="dialog-header">
        <div class="header-left">
          <div class="header-icon">
            <v-icon size="16" class="header-icon__glyph">mdi-check-decagram-outline</v-icon>
          </div>
          <div>
            <div class="header-title">Progression de validation</div>
            <div class="header-subtitle">{{ habilitationNom }}</div>
          </div>
        </div>
      
      </v-card-title>

      <v-divider />

      <v-card-text class="pa-0">
        <div
          v-for="(etape, index) in etapes"
          :key="etape.id"
          class="step-row"
        >
          <div class="step-indicator">
            <div
              class="step-circle"
              :class="'step-circle--' + resolvedStatut(etape, index)"
            >
              {{ etape.ordre }}
            </div>
            <div
              v-if="index < etapes.length - 1"
              class="step-connector"
              :class="'step-connector--' + resolvedStatut(etape, index)"
            />
          </div>

          <div class="step-content">
            <div>
              <div class="step-name">{{ etape.signataire_nom }}</div>
              <div class="step-role">{{ roleLabel(etape.role) }}</div>
              <div class="step-sub">
                <span v-if="etape.confirmed_at">
                  Validé le {{ new Date(etape.confirmed_at).toLocaleDateString('fr-FR') }}
                </span>
                <span v-else-if="isCurrentStep(index)">En attente de signature</span>
                <span v-else>En attente des étapes précédentes</span>
              </div>
            </div>

            <div
              class="step-badge"
              :class="'step-badge--' + resolvedStatut(etape, index)"
            >
              {{ statusLabel(etape, index) }}
            </div>
          </div>
        </div>
      </v-card-text>

      <v-divider />

      <v-card-actions class="dialog-footer">
        <div class="footer-progress">
          <div
            class="progress-dot"
            :class="currentStepIndex === -1 ? 'progress-dot--done' : 'progress-dot--active'"
          />
          <span class="footer-label">
            Étape {{ currentStepIndex + 1 }} sur {{ etapes.length }} en cours
          </span>
        </div>
        <v-spacer />
        <v-btn density="compact"     size="small" @click="dialog = false">Fermer</v-btn>
      </v-card-actions>

    </v-card>
  </v-dialog>
</template>
<script setup>
import { computed } from "vue"

const props = defineProps({
  modelValue: Boolean,
  habilitationNom: { type: String, default: "" },
  etapes: { type: Array, default: () => [] }
})

const emit = defineEmits(["update:modelValue"])

const dialog = computed({
  get: () => props.modelValue,
  set: (v) => emit("update:modelValue", v)
})

const currentStepIndex = computed(() =>
  props.etapes.findIndex(e => e.statut === "en_attente")
)

function isCurrentStep(index) {
  return index === currentStepIndex.value
}

// Maps raw API statut → CSS modifier key
function resolvedStatut(etape, index) {
  const s = etape.statut
  if (s === "confirme" || s === "confirmé" || s === "validé" || s === "valide") return "confirme"
  if (s === "refuse" || s === "refusé") return "refuse"
  // en_attente: only the first waiting step is "active", the rest are "inactive"
  if (s === "en_attente") {
    return isCurrentStep(index) ? "en_attente" : "inactif"
  }
  return "inactif"
}

function statusLabel(etape, index) {
  const map = {
    confirme:   "Confirmé",
    en_attente: "En attente",
    refuse:     "Refusé",
    inactif:    "En attente"
  }
  return map[resolvedStatut(etape, index)] || etape.statut
}

function roleLabel(role) {
  const map = {
    employe:             "Employé",
    manager_service:     "Manager service",
    manager_departement: "Manager département",
    resp_sst:            "Responsable SST",
    directeur:           "Directeur"
  }
  return map[role] || role
}
</script>

<style scoped>
/* ── Header ── */
.dialog-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 20px 12px;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.header-icon {
  width: 32px;
  height: 32px;
  min-width: 32px;
  min-height: 32px;
  border-radius: 8px;
  background: #E1F5EE;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.header-icon .header-icon__glyph,
.header-icon .v-icon,
.header-icon i {
  color: #0F6E56 !important;
  font-size: 16px !important;
}

.header-title {
  font-size: 14px;
  font-weight: 500;
  color: rgba(0, 0, 0, 0.87);
}

.header-subtitle {
  font-size: 12px;
  color: rgba(0, 0, 0, 0.5);
  margin-top: 1px;
}

/* ── Step row ── */
.step-row {
  display: flex;
  align-items: flex-start;
  padding: 0 20px;
}

.step-indicator {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 32px;
  flex-shrink: 0;
  margin-right: 16px;
}

/* ── Step circle ── */
.step-circle {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 13px;
  font-weight: 500;
  color: #ffffff;
  flex-shrink: 0;
  margin-top: 14px;
}

.step-circle--confirme   { background: #1D9E75; }
.step-circle--en_attente { background: #EF9F27; }
.step-circle--refuse     { background: #E24B4A; }
.step-circle--inactif    { background: transparent; border: 2px solid #D3D1C7; color: #888780; }

/* ── Connector line ── */
.step-connector {
  width: 2px;
  flex-grow: 1;
  min-height: 24px;
  margin: 2px 0;
}

.step-connector--confirme   { background: #9FE1CB; }
.step-connector--en_attente { background: #FAC775; }
.step-connector--refuse     { background: #F7C1C1; }
.step-connector--inactif    { background: #D3D1C7; }

/* ── Step content ── */
.step-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-grow: 1;
  padding: 14px 0;
}

.step-name {
  font-size: 13px;
  font-weight: 600;
}

.step-role {
  font-size: 11px;
  color: rgba(0, 0, 0, 0.4);
  margin-top: 1px;
}

.step-sub {
  font-size: 11px;
  color: rgba(0, 0, 0, 0.5);
  margin-top: 3px;
}

/* ── Status badge ── */
.step-badge {
  display: inline-flex;
  align-items: center;
  border-radius: 20px;
  padding: 4px 12px;
  font-size: 12px;
  font-weight: 500;
  white-space: nowrap;
  margin-left: 12px;
  flex-shrink: 0;
}

.step-badge--confirme {
  background: #E1F5EE;
  color: #0F6E56;
  border: 1px solid #9FE1CB;
}
.step-badge--en_attente {
  background: #FAEEDA;
  color: #854F0B;
}
.step-badge--refuse {
  background: #FCEBEB;
  color: #A32D2D;
}
.step-badge--inactif {
  background: #F1EFE8;
  color: #5F5E5A;
}

/* ── Footer ── */
.dialog-footer {
  padding: 12px 20px;
  background: rgba(0, 0, 0, 0.02);
}

.footer-progress {
  display: flex;
  align-items: center;
  gap: 8px;
}

.progress-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
}

.progress-dot--active { background: #EF9F27; }
.progress-dot--done   { background: #1D9E75; }

.footer-label {
  font-size: 12px;
  color: rgba(0, 0, 0, 0.5);
}</style>