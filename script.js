document.addEventListener('DOMContentLoaded', function () {
    const fatorInput = document.getElementById('fator');
    const nivelInicialInput = document.getElementById('nivelInicial');
    const nivelFinalInput = document.getElementById('nivelFinal');
    const polegadasInput = document.getElementById('polegadas');
    const pesoLiquidoButton = document.getElementById('pesoLiquido');
    const m3Button = document.getElementById('m3');
    const titleElement = document.getElementById('main-title'); // Elemento do título
    const errorModal = document.getElementById('errorModal'); // Modal de erro
    let currentIndex = 0;
  
    fatorInput.addEventListener('input', handleInput);
    nivelInicialInput.addEventListener('input', handleInput);
    nivelFinalInput.addEventListener('input', handleInput);
    nivelFinalInput.addEventListener('input', calculatePolegadas);
  
    document.getElementById('calculateNitrogenio').addEventListener('click', calculateNitrogenio);
    document.getElementById('calculateOxigenio').addEventListener('click', calculateOxigenio);
    document.getElementById('calculateArgonio').addEventListener('click', calculateArgonio);
    document.getElementById('clear').addEventListener('click', clearFields);
  
    // Função para exibir o modal de erro
    function showErrorModal() {
        errorModal.style.display = 'block'; // Mostra a janela de erro
    }
  
    // Função para fechar o modal de erro
    function fecharModal() {
        errorModal.style.display = 'none'; // Fecha a janela de erro
    }
  
    // Função de entrada nos campos
    function handleInput(event) {
        const input = event.target;
        let value = input.value;
  
        if (value.includes(',')) {
            value = value.replace(/,/g, '.');
            input.value = value;
        }
  
        // Adiciona a classe para mostrar a tooltip
        if (input.value) {
            input.classList.add('has-value');
        } else {
            input.classList.remove('has-value');
        }
    }
  
    // Função para calcular polegadas
    function calculatePolegadas() {
        const nivelInicial = parseFloat(nivelInicialInput.value) || 0;
        const nivelFinal = parseFloat(nivelFinalInput.value) || 0;
        const polegadas = nivelFinal - nivelInicial;
        polegadasInput.value = `${polegadas} Polegadas`;
    }
  
    // Função para formatar números
    function formatNumber(number) {
        return new Intl.NumberFormat('pt-BR').format(number);
    }
  
    // Função para calcular o gás
    function calculateGas(fator, polegadas, factor) {
        if (!fator || !polegadas) {
            showErrorModal(); // Se faltar algum valor, mostra o modal de erro
            return;
        }
  
        const rawPesoLiquido = (fator * polegadas) / factor;
        const roundedPesoLiquido = Math.ceil(rawPesoLiquido - 0.5); // Arredondamento para cima apenas se o primeiro decimal for >= 5
        const m3 = (roundedPesoLiquido * factor).toFixed(3);
        pesoLiquidoButton.textContent = `${formatNumber(roundedPesoLiquido)} kg`;
        m3Button.textContent = `${formatNumber(m3)} m³`;
    }
  
    // Função para calcular o Nitrogênio
    function calculateNitrogenio() {
        const fator = parseFloat(fatorInput.value) || 0;
        const polegadas = parseFloat(polegadasInput.value) || 0;
        calculateGas(fator, polegadas, 0.862);
    }
  
    // Função para calcular o Oxigênio
    function calculateOxigenio() {
        const fator = parseFloat(fatorInput.value) || 0;
        const polegadas = parseFloat(polegadasInput.value) || 0;
        calculateGas(fator, polegadas, 0.754);
    }
  
    // Função para calcular o Argônio
    function calculateArgonio() {
        const fator = parseFloat(fatorInput.value) || 0;
        const polegadas = parseFloat(polegadasInput.value) || 0;
        calculateGas(fator, polegadas, 0.604);
    }
  
    // Função para limpar os campos
    function clearFields() {
        fatorInput.value = '';
        nivelInicialInput.value = '';
        nivelFinalInput.value = '';
        polegadasInput.value = '';
        pesoLiquidoButton.textContent = 'Peso Líquido';
        m3Button.textContent = 'M³';
        document.querySelectorAll('.tooltip-container input').forEach(input => input.classList.remove('has-value'));
    }
  
    // A função de fechar o modal é adicionada no botão do HTML
    window.fecharModal = fecharModal;
  });
  
