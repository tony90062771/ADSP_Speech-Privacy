N = 256;    % 每256個樣本做FFT
[xin, fs] = audioread('Voice Privacy Test3.wav');  % 讀取音訊檔案
Lx = length(xin);                   % 語音信號的總長度
frame_amount = ceil(Lx / N);          % 計算幀數
nz = N * frame_amount - Lx;         % 計算需要附加到最後一幀的零值數
x_descrb = [xin; zeros(nz, 2)];      % 將零值附加到輸入信號

lx_descrb = x_descrb(:, 1);     % 提取左聲道
rx_descrb = x_descrb(:, 2);     % 提取右聲道

% 加密步驟
encrypted_frames = cell(frame_amount, 1);   %儲存每一幀的加密頻譜數據
encryption_keys = cell(frame_amount, 1);    %儲存每一幀的加密金鑰

for i = 1:frame_amount

    frame_begin = N * (i - 1) + 1;  % 計算當前幀的起始樣本索引，i從1開始
    frame_end = N * i;  % 計算當前幀的結束樣本索引

    Fs1 = fft(lx_descrb(frame_begin:frame_end)); % 快速傅立葉變換（FFT）
    
    % 多層次的加密
    num_layers = 6;  % 重複加密6次
    keys = zeros(num_layers, 1);  % 儲存這一幀使用的所有金鑰
    for layer = 1:num_layers
        encryption_key = randn(1);  
        keys(layer) = encryption_key;
        Fs1 = Fs1 * encryption_key;  % 使用不同的金鑰進行加密
    end
    
    encrypted_frames{i} = Fs1;   % 儲存加密的幀和對應的金鑰
    encryption_keys{i} = keys;   %每一幀的加密金鑰儲存陣列中
end

% 將加密的幀轉換回時間域並保存為音訊檔案
encrypted_signal = zeros(size(x_descrb));
%對每一幀正進行加密
for i = 1:frame_amount
    frame_begin = N * (i - 1) + 1; %計算當前開始位置
    frame_end = N * i;        %計算當前結束位置
    
    %加密後的頻譜數據轉換回時間域
    encrypted_signal(frame_begin:frame_end, 2) = ifft(encrypted_frames{i});
end

audiowrite('encrypted_result3.wav', encrypted_signal, fs);   % 寫入加密音訊

fade = 0.5; 
sound(fade*encrypted_signal, fs);
pause(5); 

% 解密步驟
decrypted_frames = cell(frame_amount, 1);

for i = 1:frame_amount
    Fs1_encrypted = encrypted_frames{i};
    
    keys = encryption_keys{i};   % 獲取這一幀使用的所有金鑰
    for layer = num_layers:-1:1
        encryption_key = keys(layer);  
        Fs1_encrypted = Fs1_encrypted / encryption_key;   % 使用相同的金鑰進行解密
    end
    
    decrypted_frames{i} = Fs1_encrypted;   % 儲存解密的幀
end

% 將解密的幀轉換回時間域並保存為音訊檔案
decrypted_signal = zeros(size(x_descrb));
%對每一幀進行解密
for i = 1:frame_amount
    frame_begin = N * (i - 1) + 1;  %計算當前開始位置
    frame_end = N * i;          %計算當前結束位置
    
    % 將解密的幀轉換回時間域並保存到解密信號中
    decrypted_signal(frame_begin:frame_end, 2) = ifft(decrypted_frames{i});
end

audiowrite('decrypted_result3.wav', decrypted_signal, fs);   % 寫入解密音訊

pause(5);
sound(fade*decrypted_signal, fs);
% 繪制圖表來比較原始、加密和解密後的信號
figure;

subplot(3, 1, 1);  
plot(xin);
title('原始音訊'); 
xlabel('樣本');
ylabel('振幅');

subplot(3, 1, 2);
plot(encrypted_signal(:, 2));
title('加密後的音頻');
xlabel('樣本');
ylabel('振幅');

subplot(3, 1, 3);
plot(decrypted_signal(:, 2));
title('解密後的音頻');
xlabel('樣本');
ylabel('振幅');
