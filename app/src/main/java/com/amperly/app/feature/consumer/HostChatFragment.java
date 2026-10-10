package com.amperly.app.feature.consumer;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.amperly.app.R;

public class HostChatFragment extends Fragment {

    private TextView chatHistoryText;
    private EditText chatInputEdit;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_host_chat, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        chatHistoryText = view.findViewById(R.id.chatHistoryText);
        chatInputEdit = view.findViewById(R.id.chatInputEdit);
        Button sendChatBtn = view.findViewById(R.id.sendChatBtn);

        sendChatBtn.setOnClickListener(v -> {
            String msg = chatInputEdit.getText().toString().trim();
            if (!TextUtils.isEmpty(msg)) {
                String current = chatHistoryText.getText().toString();
                chatHistoryText.setText(current + "\nConsumer: " + msg);
                chatInputEdit.setText("");
            }
        });
    }
}
