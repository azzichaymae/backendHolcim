<template>
  <div class="dashboard">

    <!-- ── Header ─────────────────────────────────────── -->
    <div class="dashboard-header">
      <div>
        <h1 class="dash-title">Dashboard</h1>
        <p class="dash-subtitle">
          {{ isManager ? `Service : ${auth.user?.service}` : 'Vue globale — tous les services' }}
        </p>
      </div>
      <button class="btn-refresh" @click="fetchAll" :disabled="loading">
        <span class="refresh-icon" :class="{ spinning: loading }" v-html="icons.refresh"></span>
        Actualiser
      </button>
    </div>

    <!-- ── Loading ────────────────────────────────────── -->
    <div class="loading-overlay" v-if="loading">
      <div class="loader"></div>
    </div>

    <template v-else>

      <!-- ── Stats Cards ────────────────────────────────── -->
      <div class="stats-grid">
        <div class="stat-card" v-for="card in statsCards" :key="card.key"
             :style="{ '--accent': card.color }">
          <div class="stat-icon" v-html="card.icon"></div>
          <div class="stat-body">
            <div class="stat-value">{{ card.value }}</div>
            <div class="stat-label">{{ card.label }}</div>
          </div>
          <div class="stat-bar">
            <div class="stat-bar-fill"
                 :style="{ width: card.percent + '%', background: card.color }">
            </div>
          </div>
        </div>
      </div>

      <!-- ── Charts Row 1 ───────────────────────────────── -->
      <div class="charts-row">

        <!-- Donut — statut breakdown -->
        <div class="chart-card">
          <div class="chart-header">
            <h3>Statut des Habilitations</h3>
            <span class="chart-badge">Répartition</span>
          </div>
          <div class="donut-wrapper">
            <Doughnut :data="donutData" :options="donutOptions" />
            <div class="donut-center">
              <div class="donut-total">{{ totalHabilitations }}</div>
              <div class="donut-label">Total</div>
            </div>
          </div>
          <div class="donut-legend">
            <div class="legend-item" v-for="item in donutLegend" :key="item.label">
              <span class="legend-dot" :style="{ background: item.color }"></span>
              <span class="legend-label">{{ item.label }}</span>
              <span class="legend-value">{{ item.value }}</span>
            </div>
          </div>
        </div>

        <!-- Bar — alertes par seuil -->
        <div class="chart-card">
          <div class="chart-header">
            <h3>Alertes par Seuil</h3>
            <span class="chart-badge">Actives</span>
          </div>
          <Bar :data="alertesBarData" :options="barOptions" />
        </div>

      </div>

      <!-- ── Charts Row 2 ───────────────────────────────── -->
      <div class="charts-row" v-if="!isManager">

        <!-- Bar — par volet -->
        <div class="chart-card chart-wide">
          <div class="chart-header">
            <h3>Habilitations par Volet</h3>
            <span class="chart-badge">Attribution</span>
          </div>
          <Bar :data="voletBarData" :options="voletBarOptions" />
        </div>

        <!-- Bar — employés par service -->
        <div class="chart-card">
          <div class="chart-header">
            <h3>Salariés par Service</h3>
            <span class="chart-badge">Effectifs</span>
          </div>
          <Bar :data="serviceBarData" :options="barOptions" />
        </div>

      </div>

      <!-- ── Expiration table ───────────────────────────── -->
      <div class="table-card">
        <div class="chart-header">
          <h3>Habilitations Expirant Bientôt</h3>
          <span class="chart-badge warning">30 jours</span>
        </div>

        <div class="table-empty" v-if="expirations.length === 0">
          <span v-html="icons.check"></span>
          Aucune habilitation n'expire dans les 30 prochains jours.
        </div>

        <div class="table-wrapper" v-else>
          <table class="exp-table">
            <thead>
              <tr>
                <th>Salarié</th>
                <th>Matricule</th>
                <th>Habilitation</th>
                <th>Volet</th>
                <th>Expiration</th>
                <th>Jours restants</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in expirations" :key="row.employee_habilitation_id">
                <td class="td-name">{{ row.employe }}</td>
                <td>{{ row.matricule }}</td>
                <td>{{ row.habilitation }}</td>
                <td>{{ row.volet }}</td>
                <td>{{ formatDate(row.date_expiration) }}</td>
                <td>
                  <span class="jours-badge"
                    :class="{
                      urgent:  row.jours_restants <= 7,
                      warning: row.jours_restants > 7 && row.jours_restants <= 30
                    }">
                    {{ row.jours_restants }}j
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

    </template>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { Doughnut, Bar } from 'vue-chartjs';
import {
  Chart as ChartJS,
  ArcElement, Tooltip, Legend,
  CategoryScale, LinearScale, BarElement, Title
} from 'chart.js';
import api           from '@/services/api';
import { useAuthStore } from '@/stores/auth';
import '@/../css/components/dashboard/dashboard.css';

ChartJS.register(ArcElement, Tooltip, Legend,
  CategoryScale, LinearScale, BarElement, Title);

const auth    = useAuthStore();
const loading = ref(true);
const stats   = ref(null);
const charts  = ref(null);
const expirations = ref([]);

const isManager = computed(() => auth.user?.role === 'Manager');

// ── Icons ─────────────────────────────────────────────
const icons = {
  employees:    `<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/></svg>`,
  valides:      `<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>`,
  expirees:     `<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>`,
  alerts:       `<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>`,
  refresh:      `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg>`,
  check:        `<svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>`,
};

// ── Fetch ─────────────────────────────────────────────
const fetchAll = async () => {
  loading.value = true;
  try {
    const [dashRes, expRes] = await Promise.all([
      api.get('/dashboard'),
      api.get('/employee-habilitations/expiring?jours=30'),
    ]);
    stats.value       = dashRes.data.stats;
    charts.value      = dashRes.data.charts;
    expirations.value = isManager.value
      ? dashRes.data.expiring_soon ?? []
      : expRes.data;
  } catch (e) {
    console.error(e);
  } finally {
    loading.value = false;
  }
};

// ── Stats cards ───────────────────────────────────────
const totalHabilitations = computed(() =>
  (stats.value?.habilitations?.valides ?? 0) +
  (stats.value?.habilitations?.expirees ?? 0)
);

const statsCards = computed(() => {
  if (!stats.value) return [];
  const s = stats.value;
  const total = totalHabilitations.value || 1;
  return [
    {
      key: 'employees',
      label: 'Total Salariés',
      value: s.employees?.total ?? 0,
      color: '#1a6b8a',
      percent: 100,
      icon: icons.employees,
    },
    {
      key: 'valides',
      label: 'Habilitations Valides',
      value: s.habilitations?.valides ?? 0,
      color: '#22c55e',
      percent: Math.round((s.habilitations?.valides / total) * 100),
      icon: icons.valides,
    },
    {
      key: 'expirees',
      label: 'Habilitations Expirées',
      value: s.habilitations?.expirees ?? 0,
      color: '#ef4444',
      percent: Math.round((s.habilitations?.expirees / total) * 100),
      icon: icons.expirees,
    },
    {
      key: 'alerts',
      label: 'Alertes Actives',
      value: s.alerts?.actives ?? 0,
      color: '#f59e0b',
      percent: 100,
      icon: icons.alerts,
    },
  ];
});

// ── Donut chart ───────────────────────────────────────
const donutLegend = computed(() => {
  if (!charts.value?.statut_breakdown) return [];
  return charts.value.statut_breakdown.map(item => ({
    label: item.label,
    value: item.value,
    color: item.color,
  }));
});

const donutData = computed(() => ({
  labels: donutLegend.value.map(i => i.label),
  datasets: [{
    data: donutLegend.value.map(i => i.value),
    backgroundColor: donutLegend.value.map(i => i.color),
    borderWidth: 0,
    hoverOffset: 6,
  }],
}));

const donutOptions = {
  cutout: '72%',
  plugins: { legend: { display: false }, tooltip: { enabled: true } },
  responsive: true,
  maintainAspectRatio: true,
};

// ── Alertes bar chart ─────────────────────────────────
const alertesBarData = computed(() => {
  const data = charts.value?.alertes_par_seuil ?? [];
  return {
    labels: data.map(i => i.label),
    datasets: [{
      label: 'Alertes',
      data: data.map(i => i.value),
      backgroundColor: data.map(i => i.color),
      borderRadius: 6,
      borderSkipped: false,
    }],
  };
});

// ── Volet bar chart ───────────────────────────────────
const voletBarData = computed(() => {
  const data = charts.value?.par_volet ?? [];
  return {
    labels: data.map(i => i.volet),
    datasets: [
      {
        label: 'Valides',
        data: data.map(i => i.valides),
        backgroundColor: '#22c55e',
        borderRadius: 4,
      },
      {
        label: 'Expirées',
        data: data.map(i => i.expirees),
        backgroundColor: '#ef4444',
        borderRadius: 4,
      },
    ],
  };
});

// ── Service bar chart ─────────────────────────────────
const serviceBarData = computed(() => {
  const data = charts.value?.employes_par_service ?? [];
  return {
    labels: data.map(i => i.service),
    datasets: [{
      label: 'Salariés',
      data: data.map(i => i.total),
      backgroundColor: '#1a6b8a',
      borderRadius: 6,
      borderSkipped: false,
    }],
  };
});

// ── Chart options ─────────────────────────────────────
const barOptions = {
  responsive: true,
  maintainAspectRatio: true,
  plugins: { legend: { display: false } },
  scales: {
    x: { grid: { display: false } },
    y: { grid: { color: '#f0f4f8' }, beginAtZero: true, ticks: { precision: 0 } },
  },
};

const voletBarOptions = {
  ...barOptions,
  plugins: { legend: { display: true, position: 'top' } },
  scales: {
    x: { grid: { display: false }, stacked: false },
    y: { grid: { color: '#f0f4f8' }, beginAtZero: true, ticks: { precision: 0 } },
  },
};

// ── Helpers ───────────────────────────────────────────
const formatDate = (dateStr) => {
  if (!dateStr) return '—';
  return new Date(dateStr).toLocaleDateString('fr-FR');
};

onMounted(fetchAll);
</script>