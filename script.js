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
  
      // Adiciona a classe para mostrar a tooltip
      if (input.value) {
        input.classList.add('has-value');
      } else {
        input.classList.remove('has-value');
      }
    }
  
    function calculatePolegadas() {
      const nivelInicial = parseFloat(nivelInicialInput.value) || 0;
      const nivelFinal = parseFloat(nivelFinalInput.value) || 0;
      const polegadas = nivelFinal - nivelInicial;
      polegadasInput.value = `${polegadas} polegadas descarregadas`;
    }
  
    function formatNumber(number) {
      return new Intl.NumberFormat('pt-BR').format(number);
    }
  
    function calculateGas(fator, polegadas, factor) {
      const rawPesoLiquido = (fator * polegadas) / factor;
      const roundedPesoLiquido = Math.ceil(rawPesoLiquido - 0.5); // Arredondamento para cima apenas se o primeiro decimal for >= 5
      const m3 = (roundedPesoLiquido * factor).toFixed(3);
      pesoLiquidoButton.textContent = `${formatNumber(roundedPesoLiquido)} kg`;
      m3Button.textContent = `${formatNumber(m3)} m³`;
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
      document.querySelectorAll('.tooltip-container input').forEach(input => input.classList.remove('has-value'));
    }
  });
  
