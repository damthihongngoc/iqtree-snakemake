# Báo cáo 21-01-2025


### 1. Snakemake là gì?

Snake make (thường viết là Snakemake) là một công cụ tự động hoá quy trình xử lý dữ liệu (workflow management system), rất hay dùng trong tin sinh học (bioinformatics) và khoa học dữ liệu.

### 2. Pipeline là gì?

Pipeline là một chuỗi các bước xử lý dữ liệu được thực hiện tuần tự, trong đó:

- Mỗi bước nhận file đầu vào (input)

- Chạy một công cụ phân tích

- Sinh ra file đầu ra (output)

- Đầu ra của bước trước là đầu vào của bước sau

## 3. Pipeline IQ-TREE trong Snakemake

Trong Snakemake:

- Pipeline = tập hợp các rule
- Mỗi rule = một bước phân tích

Snakemake tự động suy luận thứ tự chạy dựa trên mối quan hệ giữa input và output của các rule.

## 4. Cài đặt môi trường

### 4.1. Cài Conda (Miniforge)

Khuyến nghị dùng Miniforge để tránh xung đột phần mềm bioinformatics.

Các bước chính:

Tải Miniforge cho Windows (x86_64)

Mở link: https://github.com/conda-forge/miniforge

Kéo xuống mục “Latest installers”

Tìm đúng:

Miniforge3-Windows-x86_64.exe

-> Tải về và cài trên máy như bình thường, tới màn hình 4: Advanced Options thì tích Create shortcuts , Register Miniforge3 as my default Python 3.12, Clear the package cache upon completion. 

Sau khi tải xong, mở Mở Miniforge Prompt, kiểm tra conda version, bằng cách gõ
```
   conda --version
```

### 4.2. Cấu hình chuẩn cho bioinformatics
Chạy lần lượt

```
conda config --add channels conda-forge
conda config --add channels bioconda
conda config --set channel_priority strict
```

### 4.3. Cài Snakemake

Chạy lệnh

```
conda create -n snakemake snakemake
```

Nếu hiện
Proceed ([y]/n)? → gõ y rồi Enter

```
conda activate snakemake
snakemake --help
```
Nếu thấy màn hình help → cài thành công 

### Cấu trúc thư mục

```
iqtree_snakemake/
├── Snakefile
├── data/
│   ├── turtle.fa
│   ├── turtle.nex
│   └── ...
└── results/
```

## 5. Các khái niệm
### 5.1. Rule

- `rule` = một bước trong workflow

- Tương đương một lệnh chạy trong terminal

### 5.2. input

- Khai báo các file bắt buộc phải tồn tại

- Có thể đặt tên cho input để tiện sử dụng

### 5.3. output

- Khai báo file mà rule phải tạo ra

- Snakemake chỉ kiểm tra file output có tồn tại hay không, không quan tâm lệnh bên trong

### 5.4. Wildcard

- `{name}` là wildcard, đại diện cho tên dataset (turtle, covid2, ...)

- Snakemake suy ra giá trị wildcard từ output

Ví dụ:

```
data/turtle.fa → name = turtle
```

### 5.5. shell

- Chứa lệnh chạy giống hệt terminal

- `{input}`, `{output}`, `{wildcards.name}` được Snakemake tự động thay thế

## 6. Viết snakefile cho các bước 

### STEP 2 – Basic ML tree

- Input: alignment `.fa`

- Dựng cây Maximum Likelihood và đánh giá độ hỗ trợ nhánh bằng Ultrafast Bootstrap.

### STEP 3 – Partition model

- Input: `.fa` + file partition `.nex`

- Dựng cây ML với partition sẵn có

### STEP 4 – PartitionFinder (MERGE)

 Dùng MFP+MERGE để gộp partition tối ưu

- Sinh ra file `best_scheme.nex`

### STEP 5 – Topology test

- Ghép nhiều cây vào một file .trees

- Chạy AU test và các kiểm định topology

### STEP 6 – MAST / Mixture-on-trees

- Đánh giá likelihood của nhiều cây cố định

- Dùng `-n 0` để không tìm cây mới

### STEP 7 – Gene-wise log-likelihood

- Tính log-likelihood theo từng gene / partition

### STEP 8 – Remove influential genes

- Dựng lại cây sau khi loại bỏ gene ảnh hưởng mạnh

### STEP 9 – Concordance Factors (gCF / sCF)

- gCF: gene concordance factor

- sCF: site concordance factor

### STEP 10 – Mixture models

- So sánh các mô hình:

  - Best single model
  - 2-mixture
  - 4-mixture
  - 6-mixture


## 7. Rule all – Điều khiển toàn bộ workflow

rule all xác định mục tiêu cuối cùng của pipeline.


Ý nghĩa:

- Khi chạy snakemake, Snakemake sẽ cố tạo ra tất cả file trong rule all

- Tự động chạy toàn bộ các bước cần thiết trước đó

## 8. Cách chạy Snakemake

### Chạy toàn bộ workflow

```
snakemake --cores 4
```

### Chạy một dataset hoặc một bước cụ thể

```
snakemake results/step2_basic/turtle.fa.treefile --cores 4
```

Snakemake sẽ tự động chạy các bước còn thiếu.




