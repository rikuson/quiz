# quiz

Once you learn new things, you'll never forget anymore.  
`quiz` helps you reviewing what you've learned.

## Usage

### Initialize

Create `~/.quiz-store`:

```bash
$ quiz init
```

Initialize git in `~/.quiz-store`:

```bash
$ quiz git init
```

### Add quiz

````bash
$ quiz add -m rust-quiz/001-macro-count-statements
Enter contents of rust-quiz/001-macro-count-statements and press Ctrl+D when finished:

112
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
````

### Show quiz

```bash
$ quiz rust-quiz/001-macro-count-statements
```

### Edit quiz

```bash
$ quiz edit rust-quiz/001-macro-count-statements
```

### Remove quiz

```bash
$ quiz rm rust-quiz/001-macro-count-statements
```

## Dependencies

- bash
  http://www.gnu.org/software/bash/
- git
  http://www.git-scm.com/
- tree >= 1.7.0
  http://mama.indstate.edu/users/ice/tree/
- GNU getopt
  http://www.kernel.org/pub/linux/utils/util-linux/
  http://software.frodo.looijaard.name/getopt/
- GNU sed
  https://www.gnu.org/software/sed/

## Special Thanks

This is forked from [pass](https://www.passwordstore.org) which is simple password manager following Unix philosophy.  
Respect Jason Donenfeld and contributors.
