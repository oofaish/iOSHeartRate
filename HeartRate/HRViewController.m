/**
 * HRViewController.m
 * HeartRate
 *
 * Created by Laura Kassovic on 12/16/14.
 * Copyright 2014-2015 MbientLab Inc. All rights reserved.
 *
 * IMPORTANT: Your use of this Software is limited to those specific rights
 * granted under the terms of a software license agreement between the user who
 * downloaded the software, his/her employer (which must be your employer) and
 * MbientLab Inc, (the "License").  You may not use this Software unless you
 * agree to abide by the terms of the License which can be found at
 * www.mbientlab.com/terms.  The License limits your use, and you acknowledge,
 * that the Software may be modified, copied, and distributed when used in
 * conjunction with an MbientLab Inc, product.  Other than for the foregoing
 * purpose, you may not use, reproduce, copy, prepare derivative works of,
 * modify, distribute, perform, display or sell this Software and/or its
 * documentation for any purpose.
 *
 * YOU FURTHER ACKNOWLEDGE AND AGREE THAT THE SOFTWARE AND DOCUMENTATION ARE
 * PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY, TITLE,
 * NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL
 * MBIENTLAB OR ITS LICENSORS BE LIABLE OR OBLIGATED UNDER CONTRACT, NEGLIGENCE,
 * STRICT LIABILITY, CONTRIBUTION, BREACH OF WARRANTY, OR OTHER LEGAL EQUITABLE
 * THEORY ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES INCLUDING BUT NOT LIMITED
 * TO ANY INCIDENTAL, SPECIAL, INDIRECT, PUNITIVE OR CONSEQUENTIAL DAMAGES, LOST
 * PROFITS OR LOST DATA, COST OF PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY,
 * SERVICES, OR ANY CLAIMS BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY
 * DEFENSE THEREOF), OR OTHER SIMILAR COSTS.
 *
 * Should you have any questions regarding your right to use this Software,
 * contact MbientLab via email: hello@mbientlab.com
 */

#import "HRViewController.h"

static const int PULSE_SENSOR_DATA_PIN = 0;
static const int PULSE_SENSOR_ENABLE_PIN = 1;

@interface HRViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *heartImage;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bpmLabel;

@property (nonatomic) BOOL doingReset;
@property (strong, nonatomic) NSTimer *readAnalogPinTimer;

@property (nonatomic) int IBI;
@property (strong, nonatomic) NSMutableArray *rate;
@property (nonatomic) int sampleCounter;
@property (nonatomic) int lastBeatTime;
@property (nonatomic) int thresh;
@property (nonatomic) int P;
@property (nonatomic) int T;
@property (nonatomic) int amp;
@property (nonatomic) int BPM;
@property (nonatomic) bool firstBeat;
@property (nonatomic) bool secondBeat;
@property (nonatomic) bool Pulse;

@end

@implementation HRViewController

@synthesize readAnalogPinTimer, IBI, rate, sampleCounter, lastBeatTime, thresh, P, T, amp, BPM, firstBeat, secondBeat, Pulse;


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshPressed:self];
    self.heartRateLabel.text = @"0";
    self.heartRateLabel.font = FontInformationValue;
    self.bpmLabel.text = @"BPM";
    self.bpmLabel.font = FontInformationUnit;
    self.titleLabel.text = @"HEART RATE";
    self.titleLabel.font = FontHeaderTitle;
    self.heartImage.image = [UIImage imageNamed:@"Heart-Healthy.png"];
    self.rate = [NSMutableArray arrayWithCapacity:10];
    self.IBI = 1;
    self.sampleCounter = 0;
    self.lastBeatTime = 0;
    self.thresh = 256;
    self.P = 256;
    self.T = 256;
    self.amp = 100;
    self.BPM = 60;
    self.firstBeat = TRUE;
    self.secondBeat = FALSE;
    self.Pulse = FALSE;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.readAnalogPinTimer invalidate];
    
    // Set the enable pin to low to active the pulse sensor
    MBLGPIOPin *enablePin = self.device.gpio.pins[PULSE_SENSOR_ENABLE_PIN];
    [enablePin setToDigitalValue:YES];
    
    [self.device disconnectWithHandler:nil];
}

- (IBAction)refreshPressed:(id)sender
{
    if (!self.device) {
        return;
    }

    [self.readAnalogPinTimer invalidate];
    [self.heartRateLabel setText:@"0"];
    
    self.rate = nil;
    self.rate = [NSMutableArray arrayWithCapacity:10];
    self.IBI = 1;
    self.sampleCounter = 0;
    self.lastBeatTime = 0;
    self.thresh = 256;
    self.P = 256;
    self.T = 256;
    self.amp = 100;
    self.BPM = 60;
    self.firstBeat = TRUE;
    self.secondBeat = FALSE;
    self.Pulse = FALSE;
    
    [self.statusLabel setText:@"Connecting..."];
    
    [self.device connectWithHandler:^(NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Cannot connect to MetaWear, make sure it is charged and within range" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
            return;
        }
        
        // Set the enable pin to low to active the pulse sensor
        MBLGPIOPin *enablePin = self.device.gpio.pins[PULSE_SENSOR_ENABLE_PIN];
        [enablePin setToDigitalValue:NO];
        
        NSLog(@"Set up timer for GPIO pin reading");
        self.readAnalogPinTimer = [NSTimer timerWithTimeInterval:0.05f target:self selector:@selector(updateGPIOAnalogRead) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.readAnalogPinTimer forMode:NSRunLoopCommonModes];
        
        self.statusLabel.text = @"Syncing...";
    }];
}

- (IBAction)resetDevicePressed:(id)sender
{
    self.heartRateLabel.text = @"0";
    [self.readAnalogPinTimer invalidate];
    
    [self.device connectWithHandler:^(NSError *error) {
        [self.device resetDevice];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.device connectWithHandler:^(NSError *error) {
                self.doingReset = YES;
                // Reprogram and refresh the data.
                [self refreshPressed:nil];
            }];
        });
    }];
}

- (void)updateGPIOAnalogRead {
    self.statusLabel.text = @"Reading...";
    
    MBLGPIOPin *dataPin = self.device.gpio.pins[PULSE_SENSOR_DATA_PIN];
    [dataPin.analogRatio readWithHandler:^(MBLNumericData *analogNumber, NSError *error) {
        int Signal = analogNumber.value.floatValue*512;
        NSLog(@"Got this data %d",Signal);
        
        // We take a reading every 0.05 seconds
        sampleCounter += 50;                        // keep track of the time in mS with this variable
        int N = sampleCounter - lastBeatTime;       // monitor the time since the last beat to avoid noise
        NSLog(@"Time Interval %d",N);
        
        // Find the peak and trough of the pulse wave
        if(Signal < thresh && N > (IBI/5)*3){       // avoid dichrotic noise by waiting 3/5 of last IBI
            if (Signal < T){                        // T is the trough
                T = Signal;                         // keep track of lowest point in pulse wave
                NSLog(@"Through");
            }
        }
        
        if(Signal > thresh && Signal > P){          // thresh condition helps avoid noise
            P = Signal;                             // P is the peak
            NSLog(@"Peaks");
        }                                           // keep track of highest point in pulse wave
        
        // Look for the heart beat
        // Signal surges up in value every time there is a pulse
        if (N > 250){                               // avoid high frequency noise
            if ( (Signal > thresh) && (Pulse == false) && (N > (IBI/5)*3) ){
                Pulse = true;                       // set the Pulse flag when we think there is a pulse
                IBI = sampleCounter - lastBeatTime; // measure time between beats in mS
                NSLog(@"The IBI is %d",IBI);
                lastBeatTime = sampleCounter;       // keep track of time for next pulse
                
                if(secondBeat){                     // if this is the second beat, if secondBeat == TRUE
                    NSLog(@"Second beat");
                    secondBeat = FALSE;             // clear secondBeat flag
                    for(int i=0; i<=9; i++){        // seed the running total to get a realisitic BPM at startup
                        [rate insertObject:[NSNumber numberWithInt:IBI] atIndex:i];
                        //rate[i] = IBI;
                    }
                }
                
                if(firstBeat){                      // if it's the first time we found a beat, if firstBeat == TRUE
                    NSLog(@"First beat");
                    firstBeat = FALSE;              // clear firstBeat flag
                    secondBeat = TRUE;              // set the second beat flag
                    return;                         // IBI value is unreliable so discard it
                }
                
                // Keep a running total of the last 10 IBI values
                int runningTotal = 0;               // clear the runningTotal variable
                
                for(int i=0; i<=8; i++){            // shift data in the rate array
                    [rate replaceObjectAtIndex:i withObject:[rate objectAtIndex:i+1]];
                    //rate[i] = rate[i+1];            // and drop the oldest IBI value
                    runningTotal += (int)[[rate objectAtIndex:i] integerValue];
                    NSLog(@"Count %d from added %d",i, (int)[[rate objectAtIndex:i+1] integerValue]);
                    //runningTotal += rate[i];        // add up the 9 oldest IBI values
                }
                
                [rate removeObjectAtIndex:9];
                [rate insertObject:[NSNumber numberWithInt:IBI] atIndex:9];
                NSLog(@"Count 9 from added %d",(int)[[rate objectAtIndex:9] integerValue]);
                //rate[9] = IBI;                      // add the latest IBI to the rate array
                runningTotal += (int)[[rate objectAtIndex:9] integerValue];
                NSLog(@"Running Total %d",runningTotal);
                //runningTotal += rate[9];            // add the latest IBI to runningTotal
                runningTotal /= 10;                 // average the last 10 IBI values
                NSLog(@"Running Total Average %d",runningTotal);
                BPM = 60000/runningTotal;           // get the beats per minutes -> BPM
                NSLog(@"The current BMP is %d",BPM);
            }
        }
        
        if (Signal < thresh && Pulse == TRUE){      // when the values are going down, the beat is over
            Pulse = FALSE;                          // reset the Pulse flag so we can do it again
            amp = P - T;                            // get amplitude of the pulse wave
            thresh = amp/2 + T;                     // set thresh at 50% of the amplitude
            P = thresh;                             // reset these for next time
            T = thresh;
        }
        
        if (N > 2500){                              // if 2.5 seconds go by without a beat -> reset
            thresh = 250;                           // set thresh default
            P = 250;                                // set P default
            T = 250;                                // set T default
            lastBeatTime = sampleCounter;           // bring the lastBeatTime up to date
            firstBeat = true;                       // set these to avoid noise
            secondBeat = false;                     // when we get the heartbeat back
        }
        
        self.heartRateLabel.text =  [NSString stringWithFormat:@"%d",BPM];
    }];
}

@end