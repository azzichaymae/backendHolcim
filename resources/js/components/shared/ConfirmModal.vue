<template>
  <Teleport to="body">
    <div
      v-if="show"
      @click.self="$emit('cancel')"
      style="
        position:fixed;inset:0;
        background:rgba(0,0,0,0.5);
        z-index:9999;
        display:flex;
        align-items:center;
        justify-content:center;
      "
    >
      <div style="
        background:white;
        border-radius:16px;
        padding:32px;
        width:100%;
        max-width:420px;
        text-align:center;
        box-shadow:0 20px 60px rgba(0,0,0,0.2);
      ">

        <!-- Icon -->
        <div :style="`
          width:56px;height:56px;border-radius:50%;
          background:${iconBg};color:${iconColor};
          display:flex;align-items:center;justify-content:center;
          margin:0 auto 16px;
        `" v-html="icon"></div>

        <!-- Title -->
        <h3 style="font-size:1.1rem;font-weight:700;color:#1a2e44;margin:0 0 10px 0;">
          {{ title }}
        </h3>

        <!-- Message -->
        <p style="font-size:0.875rem;color:#6b7280;line-height:1.6;margin:0 0 24px 0;">
          <slot />
        </p>

        <!-- Actions -->
        <div style="display:flex;gap:10px;justify-content:center;">
          <button
            @click="$emit('cancel')"
            style="
              padding:9px 20px;
              background:#f4f6f9;
              color:#374151;
              border:none;
              border-radius:8px;
              font-size:0.875rem;
              font-weight:500;
              cursor:pointer;
            "
          >{{ cancelLabel }}</button>

          <button
            @click="$emit('confirm')"
            :disabled="loading"
            :style="`
              padding:9px 20px;
              background:${confirmBg};
              color:white;
              border:none;
              border-radius:8px;
              font-size:0.875rem;
              font-weight:600;
              cursor:pointer;
              display:flex;
              align-items:center;
              gap:6px;
              opacity:${loading ? 0.7 : 1};
            `"
          >
            <span v-if="loading" style="
              width:14px;height:14px;
              border:2px solid rgba(255,255,255,0.3);
              border-top-color:white;
              border-radius:50%;
              animation:spin 0.7s linear infinite;
              display:inline-block;
            "></span>
            <span v-else>{{ confirmLabel }}</span>
          </button>
        </div>

      </div>
    </div>
  </Teleport>
</template>

<script setup>
defineProps({
  show:         { type: Boolean,  default: false },
  title:        { type: String,   default: 'Confirmer' },
  confirmLabel: { type: String,   default: 'Confirmer' },
  cancelLabel:  { type: String,   default: 'Annuler' },
  confirmBg:    { type: String,   default: '#ef4444' },
  iconBg:       { type: String,   default: '#fef2f2' },
  iconColor:    { type: String,   default: '#ef4444' },
  icon:         { type: String,   default: '' },
  loading:      { type: Boolean,  default: false },
});

defineEmits(['confirm', 'cancel']);
</script>