#!/bin/bash
# Tek satırlık Tokyo Night bash komut satırı:  ~/klasör main ❯   (klasör mavi, git dalı mor, ok yeşil / hata kırmızı)
# Kullanım: bash komut-satiri.sh   — ~/.bashrc sonuna bir blok ekler (önce ~/.bashrc.tokyo-yedek alır).
# Kaldırmak: ~/.bashrc içindeki "tokyo-prompt" bloğunu sil.
grep -q ">>> tokyo-prompt" ~/.bashrc && { echo "zaten ekli"; exit 0; }
cp -a ~/.bashrc ~/.bashrc.tokyo-yedek
cat >> ~/.bashrc <<'EOF'

# >>> tokyo-prompt >>>
__tokyo_prompt() {
    local s=$?
    local mavi='\[\e[38;2;122;162;247m\]' mor='\[\e[38;2;187;154;247m\]'
    local yesil='\[\e[38;2;158;206;106m\]' kirmizi='\[\e[38;2;247;118;142m\]' sifir='\[\e[0m\]'
    local dal ok
    dal=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    ok=$yesil; [ "$s" -ne 0 ] && ok=$kirmizi
    PS1="\[\e]0;\w\a\]${mavi}\w${sifir}${dal:+ ${mor}${dal}${sifir}} ${ok}❯${sifir} "
    return $s
}
if [[ "$(declare -p PROMPT_COMMAND 2>/dev/null)" =~ "declare -a" ]]; then
    PROMPT_COMMAND=(__tokyo_prompt "${PROMPT_COMMAND[@]}")
else
    PROMPT_COMMAND="__tokyo_prompt${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
fi
# <<< tokyo-prompt <<<
EOF
bash -n ~/.bashrc && echo "Eklendi. Yeni terminal aç."
