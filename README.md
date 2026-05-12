# quiz

Once you learn new things, you'll never forget anymore.  
`quiz` helps you reviewing what you've learned.

This is forked from [pass](https://www.passwordstore.org) which is a simple password manager following Unix philosophy.

## Installation

### Linux

```bash
git clone https://github.com/rikuson/quiz.git
cd quiz
sudo make install
```

### macOS

`quiz` depends on GNU versions of `sed` and `getopt`, plus `tree`, on macOS:

```bash
brew install tree gnu-sed gnu-getopt
git clone https://github.com/rikuson/quiz.git
cd quiz
PREFIX=$(brew --prefix) make install
```

See [INSTALL](INSTALL) for `PREFIX`, completion paths, and other options.

## Simple Examples

### Initialize quiz store

```bash
$ quiz init
mkdir: created directory ‘/home/rikuson/.quiz-store’
Quiz store initialized
```

### Test yourself

`quiz test` (or just `quiz` with no arguments) walks every quiz interactively, comparing your answer to the stored one. Answers are case-insensitive. End a line with `\` to continue the answer on the next line — useful for quizzes whose stored answer spans multiple lines. To enter a literal trailing backslash, double it (`\\`); generally, `2n` trailing backslashes are treated as `n` literal backslashes and `2n+1` are `n` literal backslashes plus a line continuation.

````bash
$ quiz test
Q) What is the output of this Rust program?

```rust
macro_rules! m {
    ($($s:stmt)*) => {
        $(
            { stringify!($s); 1 }
        )<<*
    };
}

fn main() {
    print!(
        "{}{}{}",
        m! { return || true },
        m! { (return) || true },
        m! { {return} || true },
    );
}
```
A) _
````

For CI use, `quiz test --non-interactive` reads answers from stdin without color output and exits non-zero if any answer is wrong:

```bash
$ printf "XOR\n" | quiz test --non-interactive
```

To restrict the quiz set, write a filter script to `$QUIZ_STORE_DIR/.filters/<name>.bash` that reads quiz file paths on stdin and prints the filtered subset on stdout, then run `quiz test --filter <name>`. A default filter can be set via a `.quizrc` file at the store root containing `QUIZ_FILTER=<name>`.

### Add quiz to store

```bash
$ quiz add deep-learning/001-logical-gate
Enter question for deep-learning/001-logical-gate: Which logic gate cannot be expressed by a single-layer perceptron?
Enter answer for deep-learning/001-logical-gate: XOR
```

Alternatively, `quiz insert deep-learning/001-logical-gate`.

### Add multiline quiz to store

`quiz add -m` opens `$EDITOR` (default `vi`) twice — first on an empty buffer for the question body, then on an empty buffer for the answer body. The two buffers are assembled into a YAML file with `question: |` and `answer: |` block scalars, so you can author multi-line questions and answers without writing YAML by hand.

````bash
$ quiz add -m rust/001-macro-count-statements
Press Enter to edit the question for rust/001-macro-count-statements in vi...
# press Enter; $EDITOR opens — type the question body and save:
What is the output of this Rust program?

```rust
macro_rules! m {
    ($($s:stmt)*) => {
        $(
            { stringify!($s); 1 }
        )<<*
    };
}

fn main() {
    print!(
        "{}{}{}",
        m! { return || true },
        m! { (return) || true },
        m! { {return} || true },
    );
}
```
Press Enter to edit the answer for rust/001-macro-count-statements in vi...
# press Enter; $EDITOR reopens — type the answer body and save:
112
````

### List existing quizzes in store

```bash
$ quiz ls
Quiz Store
├── rust
│   ├── 001-macro-count-statements
│   └── 002-bitand-or-reference
├── deep-learning
│   ├── 001-logical-gate
│   └── 002-segmentation
└── aws-certification
    ├── 001-auto-scaling
    ├── 002-s3-object
    └── 003-cloud-front
```

### Find existing quizzes in store that match 002

```bash
$ quiz find 002
Search Terms: 002
├── rust
│   └── 002-bitand-or-reference
├── deep-learning
│   └── 002-segmentation
└── aws-certification
    ├── 002-s3-object
```

Alternatively, `quiz search 002`.

### Show existing quiz

```bash
$ quiz rust/001-macro-count-statements
question: How many statements does the macro count?
answer: 112
```

### Remove quiz from store

```bash
$ quiz rm rust/001-macro-count-statements
rm: remove regular file ‘/home/rikuson/.quiz-
store/rust/001-macro-count-statements.yml’? y
removed ‘/home/rikuson/.quiz-store/rust/001-macro-
count-statements.yml’
```

## Extended Git Example

Here, we initialize new quiz store, create a git repository, and then manipulate and sync quizzes.  
Make note of the arguments to the first call of quiz git push.

```bash
$ quiz init
mkdir: created directory ‘/home/rikuson/.quiz-store’
Quiz store initialized

$ quiz git init
Initialized empty Git repository in /home/rikuson/.quiz-store/.git/

$ quiz git remote add origin git@github.com:rikuson/quiz-store.git

$ quiz add whoami
Enter question for whoami: Who am I?
Enter answer for whoami: rikuson
1 file changed, 0 insertions(+), 0 deletions(-)
create mode 100644 whoami.yml

$ quiz git push -u --all
Counting objects: 4, done.
Delta compression using up to 2 threads.
Compressing objects: 100% (3/3), done.
Writing objects: 100% (4/4), 921 bytes, done.
Total 4 (delta 0), reused 0 (delta 0)
To git@github.com:rikuson/quiz-store.git
* [new branch]      master -> master
Branch master set up to track remote branch master from origin.

$ quiz add whoareyou
Enter question for whoareyou: Who are you?
Enter answer for whoareyou: anonymous
[master b9b6746] Added given quiz for whoareyou to store.
1 file changed, 0 insertions(+), 0 deletions(-)
create mode 100644 whoareyou.yml

$ quiz rm whoami
rm: remove regular file ‘/home/rikuson/.quiz-store/whoami.yml’? y
removed ‘/home/zx2c4/.quiz-store/whoami.yml’
rm 'whoami.yml'
[master 288b379] Removed whoami from store.
1 file changed, 0 insertions(+), 0 deletions(-)
delete mode 100644 whoami.yml

$ quiz git push
Counting objects: 9, done.
Delta compression using up to 2 threads.
Compressing objects: 100% (5/5), done.
Writing objects: 100% (7/7), 1.25 KiB, done.
Total 7 (delta 0), reused 0 (delta 0)
To git@github.com:rikuson/quiz-store.git
```

## Use multiple quiz-store

Create command to use another quiz-store.  
Here's example of `.zshrc`.

```zsh
rust-quiz() {
  QUIZ_STORE_DIR=~/.quiz-store-rust quiz $@
}

_rust-quiz() {
  QUIZ_STORE_DIR=~/.quiz-store-rust _quiz
}

compdef _rust-quiz rust-quiz
```

## Dependencies

- [bash](http://www.gnu.org/software/bash/)
- [git](http://www.git-scm.com/)
- [tree >= 1.7.0](http://mama.indstate.edu/users/ice/tree/)
- [yq](https://github.com/mikefarah/yq)
- [GNU getopt](http://software.frodo.looijaard.name/getopt/)
- [GNU sed](https://www.gnu.org/software/sed/)
