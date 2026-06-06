package com.ilham.gamespace;

import android.app.Service;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.Build;
import android.os.IBinder;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.ImageView;

public class OverlayService extends Service {

    private WindowManager windowManager;
    private View floatingIconView;
    private View expandedPanelView;
    private WindowManager.LayoutParams iconParams;
    private WindowManager.LayoutParams panelParams;
    private boolean isPanelExpanded = false;

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        windowManager = (WindowManager) getSystemService(WINDOW_SERVICE);

        // 1. Setup Parameter untuk tipe Overlay
        int layoutFlag;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            layoutFlag = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY;
        } else {
            layoutFlag = WindowManager.LayoutParams.TYPE_PHONE;
        }

        // 2. Setup Icon Melayang (Floating Button)
        floatingIconView = LayoutInflater.from(this).inflate(R.layout.layout_floating_icon, null);
        iconParams = new WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                layoutFlag,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE | WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
                PixelFormat.TRANSLUCENT);
        
        iconParams.gravity = Gravity.TOP | Gravity.START;
        iconParams.x = 0;
        iconParams.y = 100;

        // 3. Setup Panel Utama (Awalnya tidak ditambahkan ke layar)
        expandedPanelView = LayoutInflater.from(this).inflate(R.layout.layout_panel, null);
        panelParams = new WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                layoutFlag,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE, // Agar keyboard game tetap bisa muncul
                PixelFormat.TRANSLUCENT);
        panelParams.gravity = Gravity.CENTER;

        // Tampilkan icon pertama kali
        windowManager.addView(floatingIconView, iconParams);

        // 4. Logika Klik & Drag (Geser)
        setupDragAndClickListener();
    }

    private void setupDragAndClickListener() {
        ImageView iconImage = floatingIconView.findViewById(R.id.img_floating_icon);
        
        iconImage.setOnTouchListener(new View.OnTouchListener() {
            private int initialX;
            private int initialY;
            private float initialTouchX;
            private float initialTouchY;

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        initialX = iconParams.x;
                        initialY = iconParams.y;
                        initialTouchX = event.getRawX();
                        initialTouchY = event.getRawY();
                        return true;
                        
                    case MotionEvent.ACTION_MOVE:
                        // Logika menggeser icon
                        iconParams.x = initialX + (int) (event.getRawX() - initialTouchX);
                        iconParams.y = initialY + (int) (event.getRawY() - initialTouchY);
                        windowManager.updateViewLayout(floatingIconView, iconParams);
                        return true;
                        
                    case MotionEvent.ACTION_UP:
                        // Deteksi apakah ini klik (bukan geser)
                        int diffX = (int) (event.getRawX() - initialTouchX);
                        int diffY = (int) (event.getRawY() - initialTouchY);
                        if (Math.abs(diffX) < 10 && Math.abs(diffY) < 10) {
                            togglePanel();
                        }
                        return true;
                }
                return false;
            }
        });

        // Tombol tutup di panel
        expandedPanelView.findViewById(R.id.btn_close_panel).setOnClickListener(v -> togglePanel());
    }

    private void togglePanel() {
        if (isPanelExpanded) {
            windowManager.removeView(expandedPanelView);
            windowManager.addView(floatingIconView, iconParams);
            isPanelExpanded = false;
        } else {
            windowManager.removeView(floatingIconView);
            windowManager.addView(expandedPanelView, panelParams);
            isPanelExpanded = true;
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (floatingIconView != null) windowManager.removeView(floatingIconView);
        if (expandedPanelView != null && isPanelExpanded) windowManager.removeView(expandedPanelView);
    }
}