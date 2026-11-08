# Question 1 – Hadoop MapReduce Keyword Search

## Requirements

Before running the program, ensure that the following are installed and configured on your computer:

- Java 8 (64-bit)
- Hadoop 3.2.4
- Windows operating system

Hadoop must be configured correctly and accessible through the system PATH.

## Steps to Execute the Program

### Step 1: Download the project

Clone or download this GitHub repository to your computer.

Navigate to the `Question_1_MapReduce` project folder, which contains the Java source code, input documents and `KeywordSearch.jar` file.

### Step 2: Open Command Prompt

Open Command Prompt and navigate to the downloaded project folder:

```cmd
cd "path\to\Question_1_MapReduce"
```

Replace the path with the actual location of the folder on your computer.

### Step 3: Run the MapReduce program

Execute the following command:

```cmd
hadoop jar KeywordSearch.jar KeywordSearch input output
```

### Step 4: Enter a search keyword

When prompted, enter the keyword you want to search for.

For example:

```text
Enter keyword to search for: africa
```

### Step 5: View the results

Hadoop processes the documents in the `input` folder and saves the results in the `output` folder.

To display the results, run:

```cmd
type output\part-r-00000
```

## Important Notes

- The `input` folder contains the seven documents used for the keyword search.
- The `output` folder is generated when the program executes.
- If an `output` folder from a previous execution already exists, delete it before running the program again.
- The program runs in Hadoop local mode, so a separate Hadoop cluster is not required.
