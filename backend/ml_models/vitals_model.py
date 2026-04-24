class VitalsModel:
    def __init__(self):
        """
        Initialize any signal processing constants or state here.
        """
        # self.fs = 30 # Sampling frequency example
        pass

    def process(self, red_signal: list[float], blue_signal: list[float], duration: float, user_id: str) -> dict:
        """
        Processes raw PPG signals (Color intensities over time) to estimate vital signs.

        Args:
            red_signal (list[float]): Red channel intensity values from the camera.
            blue_signal (list[float]): Blue channel intensity values (proxy for Infrared).
            duration (float): Total measurement duration in seconds (useful to compute sampling rate = len(signal)/duration).
            user_id (str): Student identifier.

        Returns:
            dict: Expected API response shape:
            {
                "heart_rate": int,     # Estimated BPM from the frequency domain
                "spo2_estimate": int,  # Estimated SpO2 percentage from Red/Blue AC/DC ratio
                "confidence": float    # Signal quality/confidence level [0.0 - 1.0]
            }
        """
        # TODO: Implement PPG signal processing pipeline:
        # 1. Compute Sampling Frequency (Fs) = len(red_signal) / duration
        # 2. Filtering: Apply Bandpass filter (e.g., 0.7 Hz to 3.5 Hz) to remove DC baseline and high-frequency noise
        # 3. Heart Rate Extraction: Perform Fast Fourier Transform (FFT) or peak detection on filtered signal to find BPM
        # 4. SpO2 Extraction: Calculate the AC/DC ratio of Red and Blue signals and apply Beer-Lambert calibration formula
        
        raise NotImplementedError("ML Team: Implement VitalsModel.process")
