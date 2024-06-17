document.addEventListener('DOMContentLoaded', function() {
    const fatorInput = document.getElementById('fator');
    const nivelInicialInput = document.getElementById('nivelInicial');
    const nivelFinalInput = document.getElementById('nivelFinal');
    const polegadasInput = document.getElementById('polegadas');
    const pesoLiquidoButton = document.getElementById('pesoLiquido');
    const m3Button = document.getElementById('m3');

    fatorInput.addEventListener('input', handleInput);
    nivelInicialInput.addEventListener('input', handleInput);
    nivelFinalInput.addEventListener('input', handleInput);
    nivelFinalInput.addEventListener('input', calculatePolegadas);

    document.getElementById('calculateNitrogenio').addEventListener('click', calculateNitrogenio);
    document.getElementById('calculateOxigenio').addEventListener('click', calculateOxigenio);
    document.getElementById('calculateArgonio').addEventListener('click', calculateArgonio);
    document.getElementById('clear').addEventListener('click', clearFields);

    function handleInput(event) {
        const input = event.target;
        let value = input.value;

        if (value.includes(',')) {
            value = value.replace(/,/g, '.');
            input.value = value;
        }
    }

    function calculatePolegadas() {
        const nivelInicial = parseFloat(nivelInicialInput.value) || 0;
        const nivelFinal = parseFloat(nivelFinalInput.value) || 0;
        const polegadas = Math.round(nivelFinal - nivelInicial); // Arredonda para número inteiro
        polegadasInput.value = `${polegadas.toString()} "`;
    }    

    function formatNumberBrazilian(value) {
        // Converte o valor para string com o padrão brasileiro
        return value.toLocaleString('pt-BR');
    }

    function calculateGas(fator, polegadas, factor) {
        let pesoLiquido = (fator * polegadas) / factor;
    
        // Verifica se o primeiro decimal é maior ou igual a cinco
        const firstDecimal = pesoLiquido % 1;
        if (firstDecimal >= 0.5) {
            pesoLiquido = Math.ceil(pesoLiquido); // Arredonda para cima
        } else {
            pesoLiquido = Math.floor(pesoLiquido); // Arredonda para baixo
        }
    
        const m3 = pesoLiquido * factor;
        pesoLiquidoButton.textContent = `${pesoLiquido.toLocaleString('pt-BR')} kg`;
        m3Button.textContent = `${m3.toLocaleString('pt-BR', { maximumFractionDigits: 3 }).replace('.', ',')} m³`;
    }    

    function calculateNitrogenio() {
        const fator = parseFloat(fatorInput.value) || 0;
        const polegadas = parseFloat(polegadasInput.value) || 0;
        calculateGas(fator, polegadas, 0.862);
    }

    function calculateOxigenio() {
        const fator = parseFloat(fatorInput.value) || 0;
        const polegadas = parseFloat(polegadasInput.value) || 0;
        calculateGas(fator, polegadas, 0.754);
    }

    function calculateArgonio() {
        const fator = parseFloat(fatorInput.value) || 0;
        const polegadas = parseFloat(polegadasInput.value) || 0;
        calculateGas(fator, polegadas, 0.604);
    }

    function clearFields() {
        fatorInput.value = '';
        nivelInicialInput.value = '';
        nivelFinalInput.value = '';
        polegadasInput.value = '';
        pesoLiquidoButton.textContent = 'Peso Líquido';
        m3Button.textContent = 'M³';
    }
});
